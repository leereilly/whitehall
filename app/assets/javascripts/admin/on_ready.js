jQuery(document).ready(function($) {
  $(".chzn-select").chosen({allow_single_deselect: true});

  $("#completed_fact_check_requests").markLinkedAnchor();

  $('fieldset.sortable legend').each(function () {
    $(this).append(' (drag up and down to re-order)');
  })
})