
class Main extends Spine.Stack
  el: '#content'

  controllers:
    home: Home
    about: About
    sources: Sources
    source_item: SourceItem
    profile: Profile
    telescope: TelescopeStatusPage
    classify: Classify

  routes:
    '/classify': 'classify'
    '/about/:content': 'about'
    '/about': 'about'
    '/sources/:id': 'source_item'
    '/sources': 'sources'
    '/profile': 'profile'
    '/telescope_status': 'telescope'
    '/': 'home'

window.Main = Main
