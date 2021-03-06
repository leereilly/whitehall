module("Equal Height Helper", {
  setup: function() {
    this.container = $('<section class="featured_items"></section>');
    this.container.append($('<article id="item_1"></article>'));
    this.container.append($('<article id="item_2"></article>'));
    this.container.append($('<article id="item_3"></article>'));
    $('#qunit-fixture').append(this.container);

    this.container.find('#item_1').append('<h2>This is a large title which will wrap over a few lines</h2>');
    this.container.find('#item_2').append('<h2>Small title</h2>');
    this.container.find('#item_3').append('<h2>Small title</h2>');

    this.container.css({ width: "100%", background: "red"});

    // $("#qunit-fixture").css({
    //   position: 'relative',
    //   top: 'auto',
    //   left: 'auto'
    // });
  }
});

test("should resize supplied elements to equal the element with the largest height", function() {
  // set the width of the container so the largest h2 will wrap
  $("#qunit-fixture").width('200px');

  notEqual(this.container.find('#item_2 h2').css('min-height'), this.container.find('#item_1 h2').css('height'), "#item_2 h2 should not be the same size as #item_1 h2");
  ok(this.container.find('#item_2 h2').height() < this.container.find('#item_1 h2').height());

  // apply the plugin
  this.container.equalHeightHelper({selectorsToResize: ['h2'], breakpointSelector: '#qunit-fixture', breakpointWidth: 100});

  equal(this.container.find('#item_2 h2').css('min-height'), this.container.find('#item_1 h2').css('height'));
  equal(this.container.find('#item_2 h2').css('height'), this.container.find('#item_1 h2').css('height'));

  equal(this.container.find('#item_3 h2').css('min-height'), this.container.find('#item_1 h2').css('height'));
  equal(this.container.find('#item_3 h2').css('height'), this.container.find('#item_1 h2').css('height'));
});

test("if the the specified breakpoint element width is below specified breakpoint there should be no min-height restriction", function () {
  $("#qunit-fixture").width('200px');
  // apply the plugin setting the breakpoint to wider than the breakpointSelector element width
  this.container.equalHeightHelper({selectorsToResize: ['h2'], breakpointSelector: '#qunit-fixture', breakpointWidth: 300});

  equal(this.container.find('#item_2 h2').css('min-height'), "0px");
  equal(this.container.find('#item_3 h2').css('min-height'), "0px");
});