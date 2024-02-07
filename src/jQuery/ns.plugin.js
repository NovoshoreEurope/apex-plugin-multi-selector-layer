var multiSelectWindow = {
    // Variable para almacenar 'name' de forma accesible a otras funciones
    name: null,

    _initialize: function (initName, initValues) {
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
                return $(this).val();
            }).get();

            // Store the selected values
            // Convertir esos valores en un objeto JSON
            var jsonString = JSON.stringify(selectedValues);
            $s(initName, jsonString);
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
            return $('#data-multiselect-info input[type="checkbox"]:checked').map(function () {
                return $(this).val();
            }).get();
        } catch (error) {
            mostrarErrorGenerico("MultiSelectWindow error: " + error.message);
        }
    }
};