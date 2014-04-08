class FeedbackController < ApplicationController
respond_to :html, :json	
  def staff
  	name = params[:name]
  	url = params[:url]
  	agent = request.env['HTTP_USER_AGENT']
  	ip = request.env['HTTP_X_FORWARDED_FOR']
  	issue = params[:issue]
  	FeedbackMailer.feedback_email(name, url, agent, issue, ip).deliver
  	respond_to do |format|
		format.json { render :json => {:message => 'cool'}}
	end
  end
end
