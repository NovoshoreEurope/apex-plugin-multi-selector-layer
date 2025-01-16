var multiSelectWindow = {
    name: null,

    _initialize: function (selected_value_type, array_separator, initName, initValues) {
        "use strict";

        // Add an event handler to the button
        $("#b-data-multiselect-info").on("click", function () {
            $("#data-multiselect-info").slideToggle();
            changeButtonIcon();
        });

        // Add an event handler for checkbox state changes
        $('#data-multiselect-info input[type="checkbox"]').on('change', function () {
            // Filter checked checkboxes and get their values
            var selectedValues = $('#data-multiselect-info input[type="checkbox"]:checked').map(function () {
                switch (selected_value_type) {
                    case 'id':
                        return $(this).val();
                    case 'display':
                        return $(this).attr("display");
                    case 'description':
                        return $(this).attr("description");
                    default:
                        return $(this).val();
                }
            }).get();

            // Store the selected values somewhere with the provided 'name'
            $s(initName, selectedValues.join(array_separator));
        });

        // Change the button icon on click
        function changeButtonIcon() {
            let $button = $("#b-data-multiselect-info .t-Icon");
            $button.toggleClass("fa-angle-up fa-angle-down");
        }
    },

    value: function () {
        return $v(this.name);
    },

    valueAsArray: function () {
        try {
            return $v(this.name).split(array_separator);
        } catch (error) {
            mostrarErrorGenerico("MultiSelectWindow error: " + error.message);
        }
    }
};