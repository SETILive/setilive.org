(function() {
  var Workflow,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Workflow = (function(_super) {

    __extends(Workflow, _super);

    function Workflow() {
      Workflow.__super__.constructor.apply(this, arguments);
    }

    Workflow.configure('Workflow', 'description', 'version', 'questions');

    Workflow.extend(Spine.Events);

    Workflow.fetch_from_url = function(url) {
      return $.getJSON(url, function(data) {
        var workflow;
        console.log(data);
        workflow = new Workflow(data);
        return workflow.save();
      });
    };

    return Workflow;

  })(Spine.Model);

  window.Workflow = Workflow;

}).call(this);
