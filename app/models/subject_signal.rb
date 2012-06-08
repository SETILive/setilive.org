class SubjectSignal
  include MongoMapper::Document
  
  key :characteristics , Array
  key :start_coords , Array
  key :end_coords , Array
  
  belongs_to :classification
  belongs_to :observation
  belongs_to :workflow

  timestamps! 
  
  def start_point
    [start_coords[0].to_f, start_coords[1].to_f]
  end

  def end_point
    [end_coords[0].to_f, end_coords[1].to_f]
  end

  def calcIntersect
    m = calcGrad(start_point,end_point)
    end_point[1]- m* end_point[0] 
  end

  def calcMid
    (observation.height*0.5 - start_point[1])*(end_point[0]-start_point[0])/(end_point[1]-start_point[1])+start_point[0]
  end

  def grad 
    m = (end_point[1]-start_point[1])*1.0/(end_point[0]-start_point[0])
  end

  def angle
    (Math.atan2((end_point[0] - start_point[0]),(end_point[1]-start_point[1])))
  end

  def real?
    !(start_coords[0].nil? or end_coords[0].nil? or start_coords[1].nil? or end_coords[1].nil?)
  end

end
