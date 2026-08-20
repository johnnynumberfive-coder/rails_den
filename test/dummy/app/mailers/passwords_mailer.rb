class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user

    mail(
      subject: "Reset your password",
      to: user.email_address,
      template_path: "rails_den/passwords_mailer",
      template_name: "reset"
    )
  end
end
