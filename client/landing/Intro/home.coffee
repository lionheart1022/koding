class PlanSelectionView extends KDCustomHTMLView
  constructor : (options = {}, data) ->
    options.cssClass      = KD.utils.curry "plan-selection", options.cssClass

    super options, data

    @buyNowButton = new KDButtonView
      style : 'solid yellow'
      title : 'BUY NOW'

  createSlider : ->
    {plans} = @getOptions()
    slider = new KDSliderBarView
      minValue    : 0
      maxValue    : plans.length
      interval    : 1
      snapOnDrag  : yes
      handles     : [0]
      drawBar     : no
      width       : 272

    return slider

  viewAppended : JView::viewAppended

  pistachio : ->
    """
      <div class="resource-pack">
        <h6>Resource Pack</h6>
        <span class="resource cpu"><i></i> x1</span>
        <span class="resource ram"><i></i> x2</span>
        <span class="resource disk"><i></i> 1TB</span>
        <span class="resource always-on"><i></i> YES</span>
      </div>
      <div class="sliderbar-outer-container">{{> @createSlider()}}</div>
      <div class="selected-plan">
        <div class="price">
          <cite>$</cite>20
          <span>/MONTH</span>
        </div>
        <span class="description">$4 OFF OR<br> 1 SHARED VM</span>
        {{> @buyNowButton}}
      </div>
    """



class PricingBoxWithSliderView extends KDCustomHTMLView
  constructor : (options = {}, data = {}) ->
    options.cssClass       = KD.utils.curry "customize-box", options.cssClass
    options.minValue      ?= 0
    options.maxValue      ?= 100
    options.interval      ?= 1
    options.initialValue  ?= options.minValue
    options.snapOnDrag    ?= yes
    options.period        ?= "Month"
    options.unitName      ?= "Unit"
    options.unitPrice     ?= 1

    super options, data

    @unitCount = new KDCustomHTMLView
      tagName : 'strong'
      partial : @getOption 'initialValue'

    @slider = new KDSliderBarView
      minValue    : @getOption 'minValue'
      maxValue    : @getOption 'maxValue'
      interval    : @getOption 'interval'
      snapOnDrag  : @getOption 'snapOnDrag'
      handles     : [@getOption 'initialValue']
      drawBar     : no
      width       : 307

  viewAppended : JView::viewAppended

  pistachio : ->
    """
      <span class="icon"></span>
      <div class="plan-values">
        <span class="unit-display">{{> @unitCount }} #{@getOption('unitName')}</span>
        <span class="calculated-price">$300/Month</span>
      </div>
      <div class="sliderbar-outer-container">{{> @slider}}</div>
    """


class HomePage extends JView

  constructor:(options = {}, data)->

    options.domId = 'home-page'

    super options, data

    @pricingButton = new KDButtonView
      title       : "<a href='mailto:sales@koding.com?subject=Koding, white label' target='_self'>Get your own Koding for your team<cite>Contact us for details</cite></a>"
      cssClass    : 'solid green shadowed pricing'
      icon        : 'yes'
      iconClass   : 'dollar'
      click       : (event)->
        KD.mixpanel "Sales contact, click"
        KD.utils.stopDOMEvent event

    @registerForm = new HomeRegisterForm
      callback    : (formData)->
        KD.mixpanel "Register button in / a, click"
        @doRegister formData

    @registerFormBottom = new HomeRegisterForm
      callback    : (formData)->
        KD.mixpanel "Register button in / b, click"
        @doRegister formData

    @githubLink   = new KDCustomHTMLView
      tagName     : "a"
      partial     : "Or you can sign up using <strong>GitHub</strong>"
      click       : ->
        KD.mixpanel "Github auth button in /, click"
        KD.singletons.oauthController.openPopup "github"

    @markers = new MarkerController

    @planSelection = new PlanSelectionView
      plans : [
        { 'First Plan' :
          cpu        : 1
          ram        : 2
          disk       : '1TB'
          alwaysOn   : no
          price      : 20 },
        { 'Second Plan':
          cpu        : 2
          ram        : 4
          disk       : '2TB'
          alwaysOn   : yes
          price      : 40 },
        { 'Third Plan':
          cpu        : 4
          ram        : 6
          disk       : '3TB'
          alwaysOn   : yes
          price      : 60 }
      ]



    @customizeUsers = new PricingBoxWithSliderView
      cssClass    : 'users'
      minValue    : 1000
      interval    : 500
      maxValue    : 10000
      initialValue: 3000
      unitPrice   : 10
      unitName    : "Users"

    @customizeResources = new PricingBoxWithSliderView
      cssClass    : 'resources'
      minValue    : 1000
      interval    : 500
      maxValue    : 10000
      initialValue: 4000
      unitPrice   : 10
      unitName    : "Resources"


  show:->

    @appendToDomBody()  unless document.getElementById 'home-page'

    @unsetClass 'out'
    document.body.classList.add 'intro'
    KD.utils.defer => @markers.reset()

    super

  hide:->

    @setClass 'out'
    document.body.classList.remove 'intro'

    super

  viewAppended:->

    super

    vmMarker = @markers.create 'vms',
      client    : '#home-page .laptop .teamwork'
      container : this
      wait      : 1000
      message   : 'ACCESS YOUR VMS ONLINE'
      offset    :
        top     : 150
        left    : 50

    navMarker = @markers.create 'nav',
      client    : '#home-page .laptop .teamwork'
      container : this
      wait      : 1300
      message   : 'EASY ACCESS TO YOUR APPS'
      offset    :
        top     : -30
        left    : 240

    chatMarker = @markers.create 'chat',
      client    : '#home-page .laptop .teamwork'
      container : this
      wait      : 1600
      message   : 'WORK TOGETHER, HAVE FUN!'
      offset    :
        top     : 150
        left    : 700

    playMarker = @markers.create 'play',
      client    : '#home-page .laptop .teamwork'
      container : this
      wait      : 1900
      message   : 'INSTANTLY SPIN UP PLAYGROUNDS'
      offset    :
        top     : 275
        left    : 500

    logoMarker = @markers.create 'logo',
      client    : '#home-page .browser'
      container : this
      wait      : 2200
      message   : 'WHITE-LABEL KODING'
      offset    :
        top     : 25
        left    : 25

    new MixpanelScrollTracker
      attribute: 'section',
      event: '/ scroll to',
      markers: [
        { position: 362,  value: 'Teamwork screenshot'    }
        { position: 627,  value: 'Feature explanation'    }
        { position: 1495, value: 'Activity screenshot'    }
        { position: 1995, value: 'Enterprise explanation' }
        { position: 2270, value: 'Enterprise contact'     }
        { position: 2864, value: 'Scrolled to bottom'     }
      ]

  pistachio:->

    """
      <header id='home-header'>
        <div class="inner-container">
          <a href="/" class="logo"><cite></cite></a>
          <a href="/" class="logotype">Koding</a>
          <a href="/Login" class="login fr">LOGIN</a>
        </div>
      </header>
      <main>
        <div class="clearfix">
          <div class="headings-container">
            <h1 class='big-header'>Coding environment<br/>from the future</h1>
            <h2>Social development in your browser, sign up to join a great community and code on powerful VMs.</h2>
          </div>
          <div class="register-container">
            {{> @registerForm}}
            <h3>{{> @githubLink}}</h3>
          </div>
        </div>
      </main>
      <figure class='laptop'>
        <section class='teamwork'></section>
      </figure>
      <section id='home-features' class='clearfix'>
        <div class='appstore clearfix'>
          <span class='icon'></span>
          <article>
            <h4>APPSTORE</h4>Speed up with user contributed apps, or create your own app, Koding has a great toolset to interact with VMs and to build UIs around.
          </article>
        </div>
        <div class='teamwork clearfix'>
          <span class='icon'></span>
          <article>
            <h4>TEAMWORK</h4>Collaborative development environment for lecture groups, pair programming, or simply for sharing what you're doing with a total stranger.
          </article>
        </div>
        <div class='social clearfix'>
          <span class='icon'></span>
          <article>
            <h4>SOCIAL</h4>Share with the community, learn from the experts or help those who have yet to start coding. Socialize with like minded people and have fun.
          </article>
        </div>
      </section>
      <section id='home-groups'>
        <h2 class='big-header'>Groups, have your own koding</h2>
        <h3>Have all your development needs in a single private space.</h3>
        <figure class='education'></figure>
        <figure class='browser'></figure>
        <div class='group-features clearfix'>
          <div class='white-label clearfix'>
            <span class='icon'></span>
            <article>
              <h4>WHITE-LABEL KODING</h4>
              You can have your private Koding in the cloud, with your rules, your apps and your own members. Please <a id='home-contact-link' href='mailto:education@koding.com?subject=Koding, white label' target='_self'>contact us</a> for further information.
            </article>
          </div>
          <div class='school clearfix'>
            <span class='icon'></span>
            <article>
              <h4>USE IT IN YOUR SCHOOL</h4>
              Koding in the classroom, prepare your files online, share them with the whole class instantly. Collaborate live or just make your students watch what you're doing.
            </article>
          </div>
          <div class='project clearfix'>
            <span class='icon'></span>
            <article>
              <h4>CREATE PROJECT GROUPS</h4>
              Want to work on a project with your buddies and use the same resources and running instances, share a VM between your fellow developers.
            </article>
          </div>
        </div>
        {{> @pricingButton}}
      </section>
      <section id="home-pricing-plans" class="clearfix">
        <div class="inner-container">
          <p>
            We'll give you a base resource pack of
            <strong>1 GB RAM and 1x CPU Share for free when you <a href="#">sign up</a></strong>
            But you can start with a pro-pack right away
          </p>
          {{> @planSelection}}
        </div>
      </section>
      <section id="home-customize-pricing" class="clearfix">
        {{> @customizeUsers}}
        <span class="plus-icon"></span>
        {{> @customizeResources}}
        <span class="equal-icon"></span>
        <div class="custom-plan">
          <div class="plan-top">
            <h2>Custom Plan</h4>
            <div class="price">
              <cite>$</cite>360
              <span>/MONTH</span>
            </div>
          </div>
          <div>
            <a class="buy-now">Buy Now</a>
            <div class="description"><span>and get 5 free VMs</span></div>
          </div>
        </div>
      </section>
      <section id='home-bottom'>
        <h2 class='big-header'>If you are ready to go, let’s do this</h2>
        <h3 class='hidden'>Something super simple and super descriptive goes here</h3>
        {{> @registerFormBottom}}
      </section>
      <footer class='clearfix'>
        <div class='fl'>
          <a href="/" class="logo"><cite></cite></a>
          <address>
          #{(new Date).getFullYear()} © Koding, Inc. </br>358 Brannan Street, San Francisco, CA, 94107
          </address>
        </div>
        <nav>
          <a href="/Activity">Activity</a>
          <a href="/About">About</a>
          <a href="mailto:hello@koding.com" target='_self'>Contact</a>
          <a href="http://learn.koding.com/">University</a>
          <a href="http://koding.github.io/jobs/">Jobs</a>
          <a href="http://blog.koding.com">Blog</a>
        </nav>
      </footer>
    """

KD.introView = new HomePage

if location.hash in ['#!/Home', '/', '']
  KD.introView.show()

