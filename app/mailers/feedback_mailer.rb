class FeedbackMailer < ActionMailer::Base
  default from: "feedback@tadl.org"

  def feedback_email(name, url, agent, issue, ip)
    @name = name
    @url  = url
    @ip = ip
    @agent = agent
    @issue = issue
    t = Time.now
    @day_month_year = t.strftime("%m/%d/%Y")
    @hour_minute = t.strftime("%I:%M%p")
    mail(to: 'smorey@tadl.org, wjr@tadl.org, jgodin@tadl.org', subject: 'Feedback from ' + @name)
  end


end
