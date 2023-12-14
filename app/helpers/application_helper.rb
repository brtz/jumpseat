# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    additional_classes = "alert mt-3"
    flash.each do |msg_type, message|
      additional_classes += " #{bootstrap_class_for(msg_type)}"
      concat(content_tag(:div, message, class: additional_classes) do
        concat content_tag(:button, "x", class: "close", data: { dismiss: "alert" })
        concat message.html_safe
      end)
    end
    flash.clear
    nil
  end

  def default_title
    controller_name.titleize
  end

  def get_class_if_key_present?(hash, key, force = false, css_class = "active")
    (hash.key?(key) || force ? css_class : "")
  end

  def format_value(k, v)
    if v.is_a?(ActiveSupport::TimeWithZone)
      v = v.strftime("%d.%m.%Y %H:%M:%S")
    end
    if k == "doi_mail_data"
      v.gsub!("\n", "<br>")
    end
    v
  end

  def link_to_access(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?

    environment ||= {}

    access_allowed = false

    url = url_for(options)

    html_options = convert_options_to_data_attributes(options, html_options)

    if html_options.has_key?("data-method")
      environment[:method] = html_options["data-method"]
    end

    result_link = Rails.application.routes.recognize_path(url, environment) rescue nil
    access_key = ApplicationController.new.get_access_key(result_link[:controller], result_link[:action], html_options["ability"]) rescue false

    if html_options.has_key?("text")
      if html_options["text"].is_a?(TrueClass)
        text = content_tag(false, name, {}, &block)
      else
        text = html_options["text"]
      end
    end

    r_result = Rails.application.routes.recognize_path(request.url, environment) rescue nil

    if !r_result.blank? && !result_link.blank?
      if r_result[:controller] == result_link[:controller] && r_result[:action] == result_link[:action]
        if html_options.has_key? "class"
          html_options["class"] += " active"
        else
          html_options["class"] = "active"
        end
      end
    end

    access_allowed = current_user.can?(access_key) || current_user.is_admin? if user_signed_in?

    if access_allowed
      html_options["href"] ||= url
      content_tag("a", name || url, html_options, &block)
    else
      text
    end
  end

  def format_version_value(obj, key, val)
    unless val.blank?
      if key == "iban"
        val = obj.item.mask_iban
      elsif key.ends_with?("_at")
        val = val.strftime("%d.%m.%Y %H:%M:%S")
      end
    end
    val
  end

  def format_translated_keys(keys)
    arr = []
    keys = keys.flatten
    count_keys_group = keys.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
    count_keys_group.each do |k, v|
      arr << "#{v}x " + I18n.t("activerecord.attributes.#{k}")
    end
    arr.join(", ")
  end
end
