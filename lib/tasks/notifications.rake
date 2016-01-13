namespace :notifications do
  desc "Check for expired biz registrations and send notification emails"
  task :biz_expirations => :environment do |t, args|
    stack = Business.all.where.not(payment_expire: nil).order(payment_expire: :asc).limit(1000)
    biz = stack.shift
    cutoff_date = Time.now + 1.weeks
    while not biz.nil? and biz.payment_expire < cutoff_date do
      UserMailer.biz_expire_notification(biz).deliver
      biz = stack.shift
    end
  end
end
