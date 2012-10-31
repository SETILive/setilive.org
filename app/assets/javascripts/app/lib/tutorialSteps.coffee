window.tutorialSteps = [ 
          title: "Welcome to SETILive "
          text: "SETILive is an exciting new project where you can help 
          look for extraterrestrial (ET) radio signals."
          location: [255,90]
          speed:400
        ,
          title: "Real Time Data"
          text: "This image presents data directly from the Allen Telescope Array 
          (ATA). You'll look for potential ET signals in this LIVE 
          data when the telescope is ACTIVE. "
          location: [255,90]
          speed:400 
        ,
#          title: "Real Time Data"
#          text: "..If enough other people see the same signal in only one of the
#          waterfalls, it could be ET! If in more than one, it's earth-based
#          interference."#
#          location: [270,130]
#          speed:400 
#        ,
          title: "Archive Data"
          text: "When INACTIVE, we show older data and 
          you identify human-made signals which make the search for ET 
          signals difficult. You'll help us understand how to deal with them better."
          location: [255,90]
          speed:400 
        ,
          title: "Beams"
          text: "The telescope is able to look in up to three directions at once, 
          toward different stars with known planets. Data from
          each directional beam are shown below."
          location: [450, 195]
          indicatorPos: "bottom left"
          speed:400
        ,
          title: "Waterfall Diagram"
          text: "The main display presents the selected beam 
          data as a 'Waterfall Diagram', showing signal 
          frequencies left to right, as time progresses from bottom to top."
          location: [350,90]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Signals"
          text: "We ask you to mark anything that looks like a signal. Signals 
          are distinct patterns that roughly follow a particular direction or
          angle like the one you see here."
          location: [350,90]
          speed:400
          indicatorPos: "top left"
       ,
          title: "Markers"
          text: "Start by clicking anywhere along signal. Go ahead, mark a point
          on the signal. Maybe about here..."
          prompt: "Click a point"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          location: [350,90]
          speed:400
          indicatorPos: "bottom left"
        ,
          title: "Lines",
          text: "That's great! Now click a second point further up the signal.",
          location: [350,90]
          indicatorPos: "top left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          disableControls: true
          prompt: "Click a second point"
          speed:400
        ,
          title: "Lines",
          text: "Excellent! You can adjust the line by dragging the markers
          so that it follows the general direction of the signal and is about
          in the middle if the signal is wide. Go ahead, give it a try...",
          location: [350,90]
          # indicatorPos: "bottom left"
          triggers: [{elements : ".large-waterfall", action: "click"}]
          # disableControls: true
          prompt: "Drag the markers"
          speed:400
        ,
          title: "Describe",
          text: "Now, describe the signal in two steps, choosing one
          characteristic each time. If two choices apply, pick the highest on
          the list. Go ahead and make your choices...",
          triggers: [{elements : ".answer", action: "click"}]
          #disableControls: true
          location: [500,90]
          prompt: "Describe the signal"
          speed:400
        ,
          title: "Repeat"
          text: "Do this for each signal that you want to mark. Once you're 
          done, click here to move on to the next beam's waterfall.",
          location: [500,305]
          disableControls: true
          triggers: [{elements : "#next_beam", action: "click"}]
          prompt: "Click 'Next Beam'"
          indicatorPos: "right bottom "
          speed:400
        ,
          title: "Second Beam"
          text: "This 'moves you on to marking the second beam's waterfall. 
          You can always go back to another beam by clicking on it."
          location: [500,305]
          indicatorPos: "left bottom "
          speed:400
        ,
          title: "Done"
          text: "Once you're done, click here."
          disableControls: true
          triggers: [{elements : "#done", action: "click"}]
          prompt: "Click 'Done' to finish"
          location: [500,305]
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
          location: [500,305]
          indicatorPos: "bottom right"
          speed:400
        ,
          title: "Archive Data"
          text: "When the telescope is INACTIVE and not sending data, we show
          you archived waterfalls. No rush, take your time if you like."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Classify Timer"
          text: "When the telescope is ACTIVE, you get live data as it happens.
          A suggested time to finish classifying the waterfalls is counted down 
          here whenever you're looking at live data."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Live Data Expires"
          text: "We try to check as much data as we can for potential ET signals 
          before the telescope moves to new targets. With live data, 
          you can ignore any signals that show in two or more beams if you like."
          location: [510,20]
          indicatorPos: "top right"
          speed:400
        ,
          title: "Why the Rush?"
          text: "Well, if enough people see the same signal 
          in the same single waterfall, <iit> could be ET!/i> More people looking
          faster helps make sure we check all 12 sets of data before
          they expire."
          location: [510,20]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Follow-Ups"
          text: "If enough people mark a promising signal, we'll command the 
          telescope to send more data from that direction at that frequency a 
          bit later to see if it's still present."
          location: [510,20]
          # indicatorPos: "top right"
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

          location: [200,-127]
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
          location: [505,-145]
          speed: 400
        ,
          title: "Science Info"
          onShow: ->
            $("#nav li.nav_about").addClass("tutorial_select")
          onLeave: ->
            $("#nav li.nav_about").removeClass("tutorial_select")
          text: "Under 'ABOUT', click on 'Science' for more information about 
          the science and background to SETILive. "
          location: [660,-145]
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
          location: [540,-145]
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
          speed:400
        ,
          title: "Crowd Power!"
          text: "If you need help, click on 'TALK' on the top menu and look 
          on our forum."
          location: [255,90]
          # indicatorPos: "top right"
          speed:400
        ,
          title: "Let's Start the Search!"
          text: "Ok, 'SETIzen', it's time to get to work!"
          location: [255,90]
          # indicatorPos: "top right"
          onLeave: ->
            $.getJSON '/seen_tutorial', ->
              window.location = '/#/classify'
              window.location.reload()
          speed:400
]
