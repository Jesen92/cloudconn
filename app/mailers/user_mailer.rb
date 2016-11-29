class UserMailer < ApplicationMailer
  default from: 'vcc@megatrend.com'

  def generated_password(user, generated_password, locale)
    @user = user
    @generated_password = generated_password

    if locale == "hr"
      mail(to: @user.email, subject: "Korisnički detalji", template_path: 'user_mailer', template_name: 'generated_password_hr')
    else
      mail(to: @user.email, subject: "Account Details")
    end
  end

  def reset_password(user, generated_password, locale)
    @user = user
    @generated_password = generated_password

    if locale == "hr"
      mail(to: @user.email, subject: "Korisnički detalji", template_path: 'user_mailer', template_name: 'reset_password_hr')
    else
      mail(to: @user.email, subject: "Account Details", template_path: 'user_mailer', template_name: 'reset_password')
    end
  end

  def send_calculated_services(user, locale, params)
    service = Service.find_by(name: params[:service])

    @veeam_user = params[:veeam_user]
    @veeam_user_price = params[:veeam_user].downcase.include?("non") ||  params[:veeam_user].downcase.include?("ne") ? 40 : 0 #TODO ispravi include jer se promijenio prijevod dodaj - include("ne")
    @service = service.name
    @service_price = service.price
    @platform = params[:vm_server]
    @extra_vm = params[:vm_extra]
    @extra_vm_price = @extra_vm.to_i * service.VM_price.to_i
    @extra_storage = params[:storage_extra]
    @extra_storage_price = (params[:storage_extra].to_i/100) * service.storage_price
    @sum_price = @veeam_user_price + @service_price + @extra_vm_price + @extra_storage_price

    if locale == "hr"
      mail(to: user.email, subject: "Cloud Connect - Veeam ponuda", template_path: 'user_mailer', template_name: 'calculator_hr')
    else
      mail(to: user.email, subject: "Cloud Connect - Veeam offer", template_path: 'user_mailer', template_name: 'calculator')
    end
  end

  def send_contact_us(locale, name, email, subject, body)

    @name = name
    @email = email
    @subject = subject
    @body = body

    if locale == "hr"
      mail(to: @email, subject: @subject, template_path: 'user_mailer', template_name: 'contact_us_hr')
    else
      mail(to: @email, subject: @subject, template_path: 'user_mailer', template_name: 'contact_us')
    end
  end

  def send_free_trial_request(user, locale)
    @email = user.email

    if locale == "hr"
      mail(to: @email, subject:"Cloud Connect - besplatna proba", template_path: 'user_mailer', template_name: 'free_trial_hr')
    else
      mail(to: @email, subject:"Cloud Connect - free trial", template_path: 'user_mailer', template_name: 'free_trial')
    end
  end
end
