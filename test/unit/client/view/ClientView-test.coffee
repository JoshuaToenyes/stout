_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
ClientView  = require './../../../../client/view/ClientView'
Model       = require './../../../../common/model/Model'
MockBrowser = require('mock-browser').mocks.MockBrowser

class TestModel extends Model
  @property 'first'
  @property 'last'



describe 'client/view/ClientView', ->

  m = v = s1 = null

  listHTML =
    "<ul>
      <li>1</li>
      <li>2</li>
      <li>3</li>
      <li>4</li>
    </ul>"

  beforeEach ->
    mock = new MockBrowser()
    global.document = mock.getDocument()
    global.window = mock.getWindow()
    v = new ClientView()
    s1 = sinon.spy()
    m = new TestModel first: 'John', last: 'Smith'

  it 'has #tagName property', ->
    expect(v).to.have.property 'tagName'

  it 'the #tagName property default is `div`', ->
    expect(v.tagName).to.equal 'div'

  it 'has #el property', ->
    expect(v).to.have.property 'el'



  describe '#constructor()', ->

    it 'passes initialization parameters to parent View class', ->
      tmpl = ->
      model = new TestModel
      v = new ClientView(tmpl, model)
      expect(v.model).to.equal model
      expect(v.template).to.equal tmpl

    it 'automatically creates a DOM node for the view', ->
      expect(v.el.nodeName).to.equal 'DIV'

    it 'registers the `click:anchor` event', ->
      expect(v.registered 'click').to.be.true

    it 'automatically re-renders the view when the model changes', ->
      f = (model) ->
        expect(model.first).to.equal m.first
        expect(model.last).to.equal m.last
      v = new ClientView f, m
      v.render()
      v.on 'render', s1
      expect(s1.called).to.be.false
      m.first = 'Jane'
      expect(s1.calledOnce).to.be.true
      m.last = 'Doe'
      expect(s1.calledTwice).to.be.true

    it 'does not auto re-render if `renderOnChange` option set to false', ->
      v = new ClientView (->), m, {renderOnChange: false}
      v.render()
      v.on 'render', s1
      m.first = 'Jane'
      m.last = 'Doe'
      expect(s1.called).to.be.false



  describe '#select()', ->

    beforeEach ->
      v = new ClientView -> listHTML
      v.render()

    it 'returns the first matching HTMLElement', ->
      e = v.select 'li'
      expect(e).to.exist
      expect(e.textContent).to.equal '1'
      expect(e.tagName).to.equal 'LI'



  describe '#selectAll()', ->

    beforeEach ->
      v = new ClientView -> listHTML

    it 'returns an HTMLNodeList of the matching elements', ->
      v.render()
      e = v.selectAll 'li'
      expect(e).to.exist
      expect(e.length).to.equal 4

    it 'iterates the callback over each matching element', ->
      count = 0
      v.selectAll 'li', ->
        count++
      expect(count).to.equal 0
      v.render()
      v.selectAll 'li', ->
        count++
      expect(count).to.equal 4



  describe '#render()', ->

    html = '<a href="/someplace">test anchor</a>'

    beforeEach ->
      v = new ClientView -> html

    click = (el) ->
      e = document.createEvent("MouseEvents");
      e.initEvent('click', true, true);
      el.dispatchEvent e

    it 'replaces the HTML contents of the root node', ->
      expect(v.el.innerHTML).to.equal ''
      v.render()
      expect(v.el.innerHTML).to.equal html

    it 'attaches a click listener to anchors without targets', (done) ->
      v.on 'click:anchor', (evt) ->
        expect(evt.data).to.equal 'file:///someplace'
        done()
      v.render()
      a = v.el.querySelector 'a'
      click(a)

    it 'does not attach click listeners to anchors with targets', (done) ->
      html = '<a target="_blank" href="/">test anchor</a>'
      t = -> return html
      v = new ClientView t
      v.render()
      a = v.el.querySelector 'a'
      click(a)
      setTimeout done, 20

  describe '#empty()', ->

    html = '<div id="someDiv"></div>'

    beforeEach ->
      v = new ClientView -> html
      v.render()

    it 'sets the `rendered` property to `false`', ->
      expect(v.rendered).to.be.true
      v.empty()
      expect(v.rendered).to.be.false
