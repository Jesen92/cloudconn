class ServicesController < ApplicationController
  #before_filter :authenticate_active_admin_user!
  #prepend_before_action :check_captcha, only: [:subscriber_create, :contact_us]

  def index
    @subscriber = Subscriber.new unless user_signed_in?
  end

  def show
  end

  def calculator #slanje mail-a za kalkulator - registrirani korisnik
    if !current_user.spam_indicator?
      if params[:users_service][:veeam_user].empty? || params[:users_service][:service].empty? || params[:users_service][:vm_server].empty?
        flash[:calc_alert] = I18n.t("controllers.services.calc_error")
      else
        UserMailer.send_calculated_services(current_user, I18n.locale.to_s, params[:users_service]).deliver_now
        flash[:notice] = I18n.t("controllers.services.calculator")
        return redirect_to root_path
      end
    else
      flash[:calc_alert] = I18n.t("controllers.services.spam_indicator")
    end

    redirect_to services_index_path(anchor: 'CALC')
  end

  def contact_us
    unless check_service_captcha(params["g-recaptcha-response"])
      flash[:recaptcha_error] = I18n.t("controllers.services.recaptcha_error")
      return redirect_to services_index_path(anchor: 'CONTACT')
    end

    @subscriber = Subscriber.find_by(email: params[:email_form][:email])
    @user = nil

    if @subscriber.nil?
      @user = User.find_by(email: params[:email_form][:email])
      puts "Nema subscribera!"
    end

    if @subscriber.nil? && @user.nil? || !@subscriber.nil? && !@subscriber.spam_indicator? || !@user.nil? && !@user.spam_indicator?
      UserMailer.send_contact_us(I18n.locale.to_s, params[:email_form][:name], params[:email_form][:email], params[:email_form][:subject], params[:email_form][:body]).deliver_now
      flash[:notice] = I18n.t("controllers.services.contact_us")
    else
      flash[:alert] = I18n.t("controllers.services.spam_indicator")
    end

    redirect_to :back
  end

  def subscriber_create #slanje mail-a za kalkulator - neregistrirani korisnik

    @subscriber = Subscriber.new(subscriber_params)

    if Subscriber.find_by(email: @subscriber.email).nil? || !Subscriber.find_by(email: @subscriber.email).spam_indicator?
      if params[:subscriber][:veeam_user].empty? || params[:subscriber][:service].empty? || params[:subscriber][:vm_server].empty?
        flash[:calc_alert] = I18n.t("controllers.services.calc_error")
      else
        @subscriber.save if Subscriber.find_by(email: @subscriber.email).nil? && User.find_by(email: @subscriber.email).nil?
        UserMailer.send_calculated_services(@subscriber, I18n.locale.to_s, params[:subscriber]).deliver_now
        flash[:notice] = I18n.t("controllers.services.calculator")
        return redirect_to root_path
      end
    else
      flash[:calc_alert] = I18n.t("controllers.services.spam_indicator")
    end

    redirect_to services_index_path(anchor: 'CALC')
  end

  def free_trial_request
    if current_user.free_trial_requested
      flash[:alert] = I18n.t("controllers.services.free_trial_error")
    else
      UserMailer.send_free_trial_request(current_user, I18n.locale.to_s).deliver_now
      flash[:notice] = I18n.t("controllers.services.free_trial")
      current_user.free_trial_requested = true
      current_user.save(validate: false)
    end

    redirect_to root_path
  end

  def general_conditions_download
    if I18n.locale == :hr
      send_file(
          "#{Rails.root}/public/assets/OUP_Veeam Cloud Connect_web_hr.pdf",
          filename: "Uvjeti upotrebe usluge VCC.pdf",
          type: "application/pdf"
      )
    else
      send_file(
          "#{Rails.root}/public/assets/OUP_Veeam Cloud Connect_web_en.pdf",
          filename: "General terms and conditions VCC.pdf",
          type: "application/pdf"
      )
    end
  end

  private

    def check_service_captcha(recaptcha_param)
      verify_recaptcha(response: recaptcha_param)
    end

    def subscriber_params
      params.require(:subscriber).permit( :email)
    end

end
