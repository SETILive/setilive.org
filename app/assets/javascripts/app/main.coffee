
class Main extends Spine.Stack
  el: '#content'

  controllers:
    home: Home
    about: About
    badges: Badges
    sources: Sources
    source_item: SourceItem
    profile: Profile
    telescope: TelescopeStatusPage
    classify: Classify

  routes:
    '/classify/:type': 'classify'
    '/classify': 'classify'
    '/about/:content': 'about'
    '/about': 'about'
    '/sources/:id': 'source_item'
    '/sources': 'sources'
    '/profile/badges/:id': 'badges'
    '/profile': 'profile'
    '/telescope_status': 'telescope'
    '/': 'home'

window.Main = Main
