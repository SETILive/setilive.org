window.tutorialSteps = [ 
          title: "Welcome to SETILive "
          text: "SETILive is an exciting new project where you can help 
          look for extraterrestrial (ET) radio signals."
          #If you've already seen the basics, you can skip ahead to the 
          #examples of Part 2."
          location: [255,90]
          #navigate: true
          #skip: 10
          speed:200
        ,
          title: "Real Time LIVE Data"
          text: "This image presents data provided by the Allen Telescope Array 
          (ATA). You'll look for potential ET signals in this LIVE 
          data delivered only while the telescope is ACTIVE."
          location: [255,90]
          speed:200
        ,
#          title: "Real Time Data"
#          text: "..If enough other people see the same signal in only one of the
#          waterfalls, it could be ET! If in more than one, it's earth-based
#          interference."#
#          location: [270,130]
#          speed:200 
#        ,
          title: "Archive Data"
          text: "When INACTIVE, or ACTIVE but live data is unavailable, 
          we show older 
          data so you can identify human-made signals which make the search for ET 
          signals difficult. You'll help us understand how to deal with them 
          better."
          location: [255,90]
          speed:200 
        ,
          title: "Beams"
          text: "The telescope is able to look in up to three directions at once, 
          toward different stars with known planets. Data from
          each directional beam are shown below."
          location: [450, 195]
          indicatorPos: "bottom left"
          speed:200
        ,
          title: "Waterfall Diagram"
          text: "The main display presents the selected beam 
          data as a 'Waterfall Diagram', showing signal 
          frequencies left to right, as time progresses from bottom to top."
          location: [340,90]
          # indicatorPos: "top right"
          speed:200
        ,
          title: "Signals"
          text: "We ask you to classify a set of waterfalls by marking anything 
          that looks like a signal. Signals 
          are distinct patterns that roughly follow a particular direction or
          angle like the one you see here."
          location: [340,90]
          speed:200
          indicatorPos: "top left"
          
       ,
          title: "Markers"
          text: "Start by clicking anywhere along signal. Go ahead, mark a point
          on the signal. Maybe about here..."
          prompt: "Click a point"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          location: [350,90]
          speed:200
          indicatorPos: "bottom left"
        ,
          title: "Lines",
          text: "That's great! Now make a line by clicking on a second point 
          further up along the signal.",
          location: [340,90]
          indicatorPos: "top left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          prompt: "Click a second point"
          speed:200
        ,
          title: "If LIVE Data, That's it!"
          text: "Excellent! If you're marking LIVE data, you're done with that 
          signal and ready to look for and mark more in the same way. If ARCHIVE
          data, there are a couple more steps."
          location: [340,152]
          speed:200
        ,
          title: "Adjust the Line",
          text: "Whether LIVE or ARCHIVE data, you can adjust the line by 
          clicking on and dragging the markers
          so the line follows the general direction of the signal and is about
          in the middle if the signal is wide. Go ahead, give it a try...",
          location: [340,152]
          # indicatorPos: "bottom left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          prompt: "Drag a marker"
          speed:200
        ,
          title: "Describe the Signal",
          text: "If the data is ARCHIVE, describe the signal in two steps, 
          as best you can, choosing one characteristic each time. If two choices
          apply, pick the highest on the list. Click 'NEXT' for more about
          these choices...",
          #triggers: [{elements : ".workflow", action: "click"}]
          #disableControls: true
          location: [500,152]
          #prompt: "Select 'continuous'"
          speed:200
        ,
          title: "Describe the Signal",
          text: "This signal has no 'parallel' counterparts running at the
          same angle and isn't 'broken' into distinct bright and dim parts, so
          your first choice is 'continuous'. It also isn't 'erratic', 
          wavering from side to side, and it isn't spread 'wide', but is 
          'narrow'."
          #triggers: [{elements : ".answer", action: "click"}]
          #disableControls: true
          location: [500,152]
          #prompt: "Select 'continous' then 'narrow'"
          speed:200
        ,
          title: "Make your choices"
          text: "So, go ahead and make your choices. First, select 'continuous',
          then 'narrow', then click 'NEXT'..."
          location: [500,152]
          speed:200
        ,
          title: "Repeat for other Beams"
          text: "Once you've marked all the signals in one waterfall, 
          click here to move to the next beam
          and mark signals on that one.  
          You can also move between beams by clicking on them.",
          location: [450,280]
          disableControls: true
          triggers: [{elements : "#next_beam", action: "click"}]
          prompt: "Click 'Next Beam'"
          indicatorPos: "right bottom "
          speed:200
        ,
#          title: "Second Beam"
#          text: "This 'moves you on to marking the second beam's waterfall. 
#          You can always go back to another beam by clicking on it."#
#          location: [505,270]
#          indicatorPos: "left bottom "
#          speed:200
#        ,
          title: "Done"
          text: "Once you're done marking all signals in all beams, click here."
          disableControls: true
          triggers: [{elements : "#done", action: "click"}]
          prompt: "Click 'Done' to finish"
          location: [450,280]
          indicatorPos: "bottom right"
          speed:200
        ,
          title: "Be Social!"
          text: "Before you move on to the next set of waterfalls, you can
          post this data to Twitter or Facebook. This will open a
          separate tab. You can save that for later by clicking back on 
          the SETILive tab to continue classifying if you want."
          location: [450,210]
          indicatorPos: "bottom right"
          speed:200
        ,
          title: "Talk"
          text: "If you've seen something interesting in any of the waterfalls
          and want to talk about it or see what other people have said, click 
          'Yes'. This also opens a new tab that you can save for later if you 
          like."
          onShow: ->
            $("#talkYes").unbind('click')
            $("#talkNo").unbind('click')
          location: [450,280]
          indicatorPos: "bottom right"
          speed:200
        ,
          title: "Archive Data"
          text: "When the telescope is INACTIVE and not sending data, we show
          you archived waterfalls and ask you to take your time and mark ALL
          signals for later aanalysis by the science team."
          location: [450,20]
          indicatorPos: "top right"
          speed:200
        ,
          title: "Classify Progress"
          text: "When the telescope is ACTIVE, you get live data as it happens.
          You'll see your progress as how many of the available live
          waterfall sets you've classified here."
          location: [450,20]
          indicatorPos: "top right"
          speed:200
        ,
          title: "Live Data Expires"
          text: "Try to carefully check as much data as you can for potential 
          ET signals while live data is available. With live data, 
          you don't need to mark signals that show up in two or more beams."
          location: [450,20]
          #indicatorPos: "top right"
          speed:200
        ,
          title: "Why the Rush?"
          text: "If enough people see the same signal 
          in the same single waterfall, it could be ET! More people looking
          faster helps make sure we check all 12 sets of data before
          they expire. Whatever pace you 
          work at, you'll still be helping out!"
          location: [450,20]
          # indicatorPos: "top right"
          speed:200
        ,
          title: "Follow-Ups"
          text: "If enough people do mark a promising signal, an automatic request
          is sent to the 
          telescope to give us more data from that direction at that frequency a 
          bit later to see if it's still present."
          location: [450,20]
          # indicatorPos: "top right"
          speed:200
         ,
          title: "More Examples"
          text: "For information on a variety of interesting
          signals with suggestions on how to mark them,
          Click on 'Signals' under 'CLASSIFY' at any time."
          onShow: ->
               $("#nav li.nav_about").addClass("tutorial_select")
               $("#nav li.tutorial_signals").addClass("tutorial_item_selected ")

          onLeave: ->
               $("#nav li.nav_about").removeClass("tutorial_select")
               $("#nav li.tutorial_signals").removeClass("tutorial_item_selected")

          location: [163,-115]
          speed:200
          indicatorPos: "top right"
        , 
          title: "Badges"
          onShow: ->
               User.trigger("tutorial_badge_awarded")
          text: "You earn badges for various things and 
          when you're awarded one, a message appears on the 
          notification bar. Other messages also appear here."
          location: [490,-30]
          speed:200
          indicatorPos: "top left"

        ,
          title: "Profile"
          text: "On your Profile Page, view waterfalls you've seen,
          ones you've favourited, your badges, and your statistics.
          Click on 'Profile' under your USERNAME at any time."
          onShow: ->
            $("#nav li.nav_user").addClass("tutorial_select")
            $("#nav li.tutorial_profile").addClass("tutorial_item_selected ")
          onLeave: ->
            $("#nav li.nav_user").removeClass("tutorial_select")
            $("#nav li.tutorial_profile").removeClass("tutorial_item_selected")
          indicatorPos: "top right"
          location: [470,-133]
          speed: 400
        ,
          title: "Science Info"
          onShow: ->
            $("#nav li.nav_about").addClass("tutorial_select")
          onLeave: ->
            $("#nav li.nav_about").removeClass("tutorial_select")
          text: "Under 'ABOUT', click on 'Science' for more information about 
          the science and background to SETILive. "
          location: [680,-133]
          speed: 400
          indicatorPos: "top left"
        ,
          title: "Rerun the Tutorial"
          text: "At any time you can also repeat this tutorial by clicking the
          'Tutorial' link under 'CLASSIFY'."
          onShow: ->
            $("#nav li.nav_classify").addClass("tutorial_select")
            $("#nav li.tutorial_tutorial").addClass("tutorial_item_selected ")
          onLeave: ->
            $("#nav li.nav_classify").removeClass("tutorial_select")
            $("#nav li.tutorial_tutorial").removeClass("tutorial_item_selected")
          location: [580,-133]
          speed: 400
          indicatorPos: "top "
        ,
          title: "Crowd Power!"
          text: "Don't worry about making mistakes. You won't harm anything. We 
          depend on majority rule on classifying the signals - you're not 
          alone...
          "
          location: [255,90]
          # indicatorPos: "top right"
          speed:200
        ,
          title: "Crowd Power!"
          text: "If you need help, click on 'TALK' on the top menu and look 
          on our forum."
          location: [255,90]
          # indicatorPos: "top right"
          speed:200
        ,
          title: "Let's Start the Search!"
          text: "Ok, 'SETIzen', let's start classifying!"
          location: [255,90]
          # indicatorPos: "top right"
          onLeave: ->
            $.getJSON '/seen_tutorial', ->
              window.location = '/#/classify'
              window.location.reload()
          speed:200
]
