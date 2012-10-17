window.tutorialSteps = [ 
          title: "Welcome to SETILive "
          text: "SETILive is an exciting new project to try and detect 
          Extraterrestrial signals"
          location: [270,130]
          speed:400
        ,
          title: "Real Time Data"
          text: "This image presents data directly from the Allen Telescope Array 
          (or 'ATA') when it is ACTIVE. Help us by looking for potential 
          Extraterrestrial signals in this LIVE data..."
          location: [270,130]
          speed:400 
        ,
          title: "Real Time Data"
          text: "..If enough other people see the same signal in only one of the
          waterfalls, it could be ET! If in more than one, it's earth-based
          interference."
          location: [270,130]
          speed:400 
        ,
          title: "Archive Data"
          text: "When the telescope is INACTIVE, we show you older data and ask 
          you to characterize those interference signals to help us analyse them."
          location: [270,130]
          speed:400 
        ,
          title: "Beams"
          text: "The telescope can look in up to three directions at once, 
          toward different stars with known planets. Data from
          each directional beam are shown here."
          location: [540, 250]
          indicatorPos: "bottom left"
          speed:400
        ,
          title: "Main Beam"
          text: "We will work on one beam at a time. The main display shows 
          the data from the currently selected beam highlighted below."
          location: [350,130]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Waterfalls"
          text: "We ask you to mark anything that looks like a signal on this 
          waterfall diagram. Signals are distinct patterns like
          the one  you can see here."
          location: [350,130]
          speed:400
          indicatorPos: "top left"
       ,
          title: "Markers"
          text: "Start by clicking anywhere along the bright signal you 
          can see here"
          prompt: "Click a point"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          location: [350,130]
          speed:400
          indicatorPos: "bottom left"
        ,
          title: "Lines",
          text: "Great! Now click a second point along the signal.",
          location: [360,120]
          indicatorPos: "top left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          prompt: "Click a second point"
          speed:400
        ,
          title: "Lines",
          text: "Excellent! You can adjust the line by dragging the markers
          so that the line follows the general direction of
          the signal. Give it a try...",
          location: [350,120]
          # indicatorPos: "bottom left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          # disableControls: true
          prompt: "Click a second point"
          speed:400
        ,
          title: "Describe",
          text: "Now, describe the signal in two steps, choosing one
          characteristic each time. If two choices apply, pick the highest on
          the list. Go ahead and make your choices...",
          triggers: [{elements : ".answer", action: "click"}]
          #disableControls: true
          location: [500,120]
          prompt: "Describe the signal"
          speed:400
        ,
          title: "Repeat"
          text: "Do this for each signal you can see in the data. Once you're 
          done, click here to move on to the next beam's waterfall.",
          location: [490,295]
          disableControls: true
          triggers: [{elements : "#next_beam", action: "click"}]
          prompt: "Click next beam"
          indicatorPos: "right bottom "
          speed:400
        ,
          title: "Second Beam"
          text: "This 'moves you on to marking the second beam's waterfall. 
          You can always go back to another beam by clicking on it."
          location: [490,295]
          indicatorPos: "left bottom "
          speed:400
        ,
          title: "Done"
          text: "Once you're done, click here."
          disableControls: true
          triggers: [{elements : "#done", action: "click"}]
          prompt: "Click to finish"
          location: [490,295]
          indicatorPos: "bottom right"
          speed:400
        ,
          title: "Talk"
          text: "If you've seen anything unusual in any of the waterfalls
          and want to talk about it or see what other people have said, click 
          'Yes'."
          onShow: ->
            $("#talkYes").unbind('click')
            $("#talkNo").unbind('click')
          location: [490,295]
          indicatorPos: "bottom right"
          speed:400
        ,
          title: "Classify Timer"
          text: "When the telescope is ACTIVE, you get live data as it happens
          A suggested time to finish classifying the waterfalls is counted down 
          here..."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Classify Timer"
          text: "...We should classify as many signals as we can before the telescope
          moves on to the next set of Kepler planets..."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Follow-Ups"
          text: "...Why the rush? If enough other people see the same signal 
          in the same waterfall, it could be ET..."
          location: [510,20]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Follow-Ups"
          text: "... We'll then command the telescope 
          to send more data from that direction at that frequency a bit later 
          to see if it's still present."
          location: [510,20]
          # indicatorPos: "top right"
          speed:400
         ,
          title: "Archive Data"
          text: "When the telescope is INACTIVE and not sending data, we show
          you archived waterfalls..."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Archive Data"
          text: "...We ask that you mark them to help us analyze
          the many interfering signals (RFI) that humans produce. No rush - 
          take your time if you like."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
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

          location: [227,-122]
          speed:400
          indicatorPos: "top right"
        , 
          title: "Badges"
          onShow: ->
               User.trigger("tutorial_badge_awarded")
          text: "You earn badges for various things and 
          when you're awarded one, a message appears on the 
          notification bar. Other messages also appear here."
          location: [490,-20]
          speed:400
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
          location: [530,-122]
          speed: 400
        ,
          title: "Science Info"
          onShow: ->
            $("#nav li.nav_about").addClass("tutorial_select")
          onLeave: ->
            $("#nav li.nav_about").removeClass("tutorial_select")
          text: "Under 'ABOUT', click on 'Science' for more information about 
          the science and background to SETILive. "
          location: [685,-122]
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
          location: [580,-122]
          speed: 400
          indicatorPos: "top "
        ,
          title: "Crowd Power!"
          text: "Don't worry about making mistakes. You won't harm anything. We 
          depend on majority rule on classifying the signals - you're not 
          alone...
          "
          location: [270,130]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Crowd Power!"
          text: "...If you need help, click on 'TALK' on the top menu and look 
          on our forum."
          location: [270,130]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Let's Get Classifying!"
          text: "Ok, 'SETIzen', it's time to get to work."
          location: [270,130]
          # indicatorPos: "top right"
          onLeave: ->
            $.getJSON '/seen_tutorial', ->
              window.location = '/#/classify'
          speed:400
]
