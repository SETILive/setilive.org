# rake signals_marked_correction<[number (optional=>200)]> <RAILS_ENV=production>

task :signals_marked_correction, [:n_todo] => :environment do |t, args|
  args.with_defaults( :n_todo => "200" )
  puts "todo: " + args.n_todo
  f_user_ids_name = "/home/nigra/Working/SETI/code/signals_fix/signals_fix_user_ids.txt"
  f_user_next_index_name = "/home/nigra/Working/SETI/code/signals_fix/signals_fix_user_next_index.txt"
  f_log_name = "/home/nigra/Working/SETI/code/signals_fix/00_signals_fix_log.txt"
  unless File.exist?(f_user_ids_name)
    f_user_ids = File.open(f_user_ids_name, 'w')
    f_user_next_index = File.open(f_user_next_index_name, 'w')
    us = ZooniverseUser.where(:updated_at => 
        { :$gt => Time.utc(2012,11,13,12,0,0) } ).to_a #.sort(:total_signals.desc).to_a
    us.each { |u| f_user_ids.puts( u.id.to_s ) }
    f_user_next_index.puts( "0" )
    f_user_ids.close()
    f_user_next_index.close()
  end
  
  u_ids = IO.readlines( f_user_ids_name )
  u_index = IO.readlines( f_user_next_index_name )[0].to_i

  badge_id = Badge.where(:title => "signals_marked").first.id.to_s
  # Get users who have done something since the bug was introduced
  nu = u_ids.count
  n_end = [ nu, u_index + args.n_todo.to_i ].min
  mu = 0
  while ( u_index < n_end ) do
    u_id = u_ids[u_index].gsub("\n", "")
    u = ZooniverseUser.find(u_id)
    uname = u.name.sub('/', '_fslash_')
    f = File.new( "/home/nigra/Working/SETI/code/signals_fix/signals_fix_#{uname}.txt", 'w' )
    
    # Users' classifications from bug introduction to bug fix
    puts "#{Time.now.utc.to_s} getting #{u.name}'s classifications"
    f_log = File.open( f_log_name, 'a')
    f_log.puts( "#{Time.now.utc.to_s} getting #{u.name}'s classifications" )
    cs=u.classifications.where(:created_at => 
        {'$gt'=>Time.utc(2012,11,13,0,0,0), 
          '$lt'=>Time.utc(2012,12,18,0,0,0) } ).sort(:created_at).to_a
    nc = cs.count
    mc = 0
    ndel = 0
    nss = 0
    tot_sigs_old = u.total_signals
    puts "  stepping through #{u.name}'s #{nc.to_s} classifications"
    cs.each do |c|
        subj = c.subject
        tempstr = ""
        mc += 1
        puts "    #{u.name}'s classification #{mc.to_s} of #{nc.to_s}" if mc%100 == 0
        c.subject_signals.each do |ss|
            keep = false
            o_test = ss.observation
            subj.observations.each do |o|
                keep |= ( o.id == o_test.id )
            end
            unless keep 
                ss.destroy
                ndel += 1
            end
            nss += 1
            tempstr += ( keep ? "o" : "x" )
        end
        f.puts( c.created_at.to_s + " " + ndel.to_s + " of " + nss.to_s + " " + tempstr )
    end
    f.close()
    f_log.close()
    puts "  re-calculating #{u.name}'s signal stats"
    u.recalculate_signal_stats
    puts "  re-awarding #{u.name}'s badges"
    bs= u.badges;
    i_del = []
    bs.each_with_index do |b,i|;
        i_del << i if ( b["id"] == badge_id );
    end;
    i_del.reverse.each do |i|
        bs.delete_at(i)
    end
    u.save
    mu += 1
    puts "  #{u.name} signals corrected from #{tot_sigs_old.to_s} to 
      #{u.total_signals} (#{(u_index+1).to_s} of #{nu})"
    u_index += 1
    f_user_next_index = File.open(f_user_next_index_name, 'w')
    f_user_next_index.puts( u_index.to_s )
    f_user_next_index.close()
  end
end

