
$(document).ready(function () {
  var amountSelector = $("input[name='amount_selector']"),
      amountInput = $('#user_collaboration_amount');

  if (amountSelector.length && amountInput.length) {
    amountSelector.change(function() {
      var amount;

      if ($(this).is(":checked")) {
        amount = $(this).val();
        if (amount !== 'other') {
          amountInput.parent().hide();
          amountInput.val(amount);
        } else {
          amountInput.parent().show();
          amountInput.focus();
          amountInput.val('');
        }
      }
    });

    amountSelector.change();
  }
});