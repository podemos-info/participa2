// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function () {
  'use strict';

  var amountsInput = $('#collaboration_amounts'),
      defaultAmountSelect = $('#collaboration_default_amount');

  if (amountsInput.length && defaultAmountSelect.length) {
    amountsInput.change(function () {
      var values = $(this).val().split(','),
          intValues = [],
          value,
          i,
          l;

      for (i = 0, l = values.length; i < l; i += 1) {
        value = parseInt(values[i], 10);
        if (!isNaN(value) && intValues.indexOf(value) === -1) {
          intValues.push(value);
        }
      }

      intValues.sort(function (a, b) { return a - b; });

      defaultAmountSelect.find('option').remove().end();

      for (i = 0, l = intValues.length; i < l; i += 1) {
        defaultAmountSelect
          .append(
            $('<option></option>')
              .attr('value', intValues[i])
              .text(intValues[i])
          );
      }

      defaultAmountSelect.val(defaultAmountSelect.data('value'));
    });

    amountsInput.change();
  }
});