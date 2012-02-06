class TargetsShow extends Spine.Controller 
  constructor : ->
    

class TargetsIndex extends Spine.Controller 
  constructor : -> 
    

class Targets extends Spine.Stack
  controllers:
    show: TargetsShow 
    index: TargetsIndex 

  default: 'index'

  routes:
    '/targets/'    : 'index'
    '/targets/:id' : 'show'

window.Targets = Targets