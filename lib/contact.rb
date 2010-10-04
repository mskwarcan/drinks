require 'pony'

class ContactForm
  attr_accessor :subject, :message, :email, :errors
  
  def initialize(options = {})
    self.subject = options[:subject] unless options[:subject] == nil
    self.message = options[:message] unless options[:message] == nil
    self.email = options[:email] unless options[:email] == nil
    
    self.errors ||= {}
  end
  
  def clear
    self.instance_variables.each do |v|
      self.instance_variable_set v, nil
    end
    self.errors ||= {}
  end
  
  def send_email(subject)
    body = <<EOM
You just received a website comment.

From: #{self.subject}
Email: #{self.email}
Message: #{self.message}
EOM
    Pony.mail(:to => 'info@drinkr.net', :from => "#{self.email}",
        :subject => "#{subject} from #{self.subject}",
        :body => body,
        :via => :smtp, :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '25',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :domain => ENV['SENDGRID_DOMAIN']
      })
  end
  
  def valid?
    self.errors[:email] = "needs to be a valid email address." unless self.email =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    self.errors[:email] = "is required." if self.email.nil? || self.email.strip.empty?
    self.errors[:subject] = "is required." if self.subject.nil? || self.subject.strip.empty?
    self.errors[:message] = "is required." if self.message.nil? || self.message.strip.empty?
    self.errors.length == 0
  end
end