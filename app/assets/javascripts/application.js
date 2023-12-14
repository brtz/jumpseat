//= require jquery
//= require jquery_ujs
//= require bootstrap.min
$.rails.allowAction = function (link) {
    if (link.data("confirm") == undefined) {
        return true;
    }
    $.rails.showConfirmDialog(link);
    return false;
};
$.rails.confirmed = function (link) {
    link.data("confirm", null);
    link.trigger("click.rails");
    return true;
};
$.rails.showConfirmDialog = function (link) {
    var html;
    msg = link.attr('data-confirm');
    modal = link.attr('data-modal');
    href = link.attr('href');
    method = link.attr("data-method");
    title = link.attr("title");
    if (title === undefined) {
        title = "";
    }
    html = '<div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true"><div class="modal-dialog modal-dialog-centered" role="document"><div class="modal-content"><div class="modal-header"><h5 class="modal-title" id="exampleModalCenterTitle">' + title + '</h5><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body">' + msg + '</div><div class="modal-footer"><button type="button" class="btn btn-sm btn-outline-danger" data-dismiss="modal">Abbrechen</button><button type="button" class="btn btn-sm btn-outline-success confirm">Bestätigen</button></div></div></div></div>';
    $html = $(html);
    $html.modal();
    var $dialog = $html.find('.confirm');
    return $dialog.on('click', function (a) {
        $a = $(this);
        $a.addClass('disabled').attr("disabled", "disabled").text('Loading');

        if (modal) {
            link.data("confirm", null);
            if (method == "delete") {
                $.delete(href, function (data, textStatus, xhr) {
                    url = xhr.getResponseHeader('Location');
                    $.get(url, function (data) {
                        $('.modal-backdrop').remove();
                        return $(modal_holder_selector).html(data).find(modal_selector).modal();
                    });
                });
            } else {
                $.get(href, function (data) {
                    $(modal_holder_selector).html(data).find(modal_selector).modal();
                });
            }
            $html.modal('hide');
            return true;
        } else {
            confirm = $.rails.confirmed(link);
            if (confirm) {
                $html.modal('hide');
                return confirm;
            }
        }

    });
};
modal_holder_selector = '#modal-holder';
modal_selector = '.modal';
$(document).on('click', 'a[data-modal="true"]', function () {
    $a = $(this);
    var location = $a.attr('href');
    var oldText = $a.text();

    $spinner = $('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>');
    $a.addClass('disabled').attr("disabled", "disabled").text(' Loading');
    $a.prepend($spinner);

    $spinner = $('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>');
    $.get(location, function (data) {
        $('.modal-backdrop').remove();
        $a.text(oldText);
        $a.find(".spinner-border").remove();
        $a.removeClass('disabled');
        $a.removeAttr('disabled');
        return $(modal_holder_selector).html(data).find(modal_selector).modal();
    });
    return false;
});
