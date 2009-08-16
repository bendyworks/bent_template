# This file uses duck typing to be swappable for webrat_steps.rb when using safariwatir
if ENV['run_watir']
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
  require 'safariwatir'

  def browser
    @browser ||= begin
      kill_file = 'tmp/pids/server.pid'
      if File.exists?(kill_file)
        pid = File.read(kill_file)
        system "kill -9 #{pid}"
        File.delete(kill_file)
      end
      system 'ruby script/server -p 3001 -e test -d'
      sleep 3
      b = Watir::Safari.new
      b.set_slow_speed
      b
    end
  end

  class BrowserShim
    def initialize browser
      @browser = browser
    end
    def body
      @browser.html
    end
  end

  def response
    BrowserShim.new(browser)
  end

  # After do
  #   # browser.close
  # end
  
  Given /^I open a browser$/ do
    browser
  end

  When /^I follow "([^\"]*)" within the row containing "([^\"]*)"$/ do |link_str, sibling_str|
    ng = Nokogiri::HTML(response.body)
    href = ng.search("//td[text()='#{sibling_str}']/..//a[text()='#{link_str}']").attr('href')
    Then('I follow "%s" via href' % href)
  end

  Then /^a box with class "([^\"]*)" should have text "([^\"]*)"$/ do |klass, timeslot|
    sleep 0.5
    the_link = browser.link(:class, klass)
    the_link.should exist
    the_link.text.should include(timeslot)
  end

  When /^I pause "([^\"]*)" seconds?$/ do |num_seconds|
    sleep num_seconds.to_i
  end

  Given /^I am on (.+)$/ do |page_name|
    browser.goto(watir_path_to(page_name))
  end

  When /^I go to (.+)$/ do |page_name|
    browser.goto(watir_path_to(page_name))
  end

  When /^I press "([^\"]*)"$/ do |button|
    browser.button(:value, button).click
    # sleep 2
  end

  When /^I follow "([^\"]*)"$/ do |target|
    browser.link(:text, /^#{target}/).click
  end

  When /^I follow "([^\"]*)" via href$/ do |href|
    link = browser.link(:url, "http://localhost:3001#{href}")
    link.should exist
    link.click
  end

  When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |label_text, value|
    lbl = browser.label(:text, /^#{label_text}/)
    lbl.should exist
    target_id = lbl.target_id
    browser.text_field(:id, target_id).set(value)

    # browser.text_field(:label, label_text).set(value)
    sleep 1
  end

  When /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, field|
    lbl = browser.label(:text, /^#{field}/)
    lbl.should exist
    target_id = lbl.target_id
    browser.select_list(:id, target_id).select(value)
  end

  # Use this step in conjunction with Rail's datetime_select helper. For example:
  # When I select "December 25, 2008 10:00" as the date and time 
  When /^I select "([^\"]*)" as the date and time$/ do |time|
    raise 'Not implemented yet!'
    # select_datetime(time)
  end

  # Use this step when using multiple datetime_select helpers on a page or 
  # you want to specify which datetime to select. Given the following view:
  #   <%= f.label :preferred %><br />
  #   <%= f.datetime_select :preferred %>
  #   <%= f.label :alternative %><br />
  #   <%= f.datetime_select :alternative %>
  # The following steps would fill out the form:
  # When I select "November 23, 2004 11:20" as the "Preferred" date and time
  # And I select "November 25, 2004 10:30" as the "Alternative" date and time
  When /^I select "([^\"]*)" as the "([^\"]*)" date and time$/ do |datetime, datetime_label|
    raise 'Not implemented yet!'
    # select_datetime(datetime, :from => datetime_label)
  end

  # Use this step in conjunction with Rail's time_select helper. For example:
  # When I select "2:20PM" as the time
  # Note: Rail's default time helper provides 24-hour time-- not 12 hour time. Webrat
  # will convert the 2:20PM to 14:20 and then select it. 
  When /^I select "([^\"]*)" as the time$/ do |time|
    raise 'Not implemented yet!'
    # select_time(time)
  end

  # Use this step when using multiple time_select helpers on a page or you want to
  # specify the name of the time on the form.  For example:
  # When I select "7:30AM" as the "Gym" time
  When /^I select "([^\"]*)" as the "([^\"]*)" time$/ do |time, time_label|
    raise 'Not implemented yet!'
    # select_time(time, :from => time_label)
  end

  # Use this step in conjunction with Rail's date_select helper.  For example:
  # When I select "February 20, 1981" as the date
  When /^I select "([^\"]*)" as the date$/ do |date|
    raise 'Not implemented yet!'
    # select_date(date)
  end

  # Use this step when using multiple date_select helpers on one page or
  # you want to specify the name of the date on the form. For example:
  # When I select "April 26, 1982" as the "Date of Birth" date
  When /^I select "([^\"]*)" as the "([^\"]*)" date$/ do |date, date_label|
    raise 'Not implemented yet!'
    # select_date(date, :from => date_label)
  end

  When /^I check "([^\"]*)"$/ do |label_text_or_id|
    if label_text_or_id[0,1] == '#'
      target_id = label_text_or_id.sub(/^#/, '')
    else
      lbl = browser.label(:text, /^#{Regexp.escape(label_text_or_id)}/)
      lbl.should exist
      target_id = lbl.target_id
      target_id.should_not be_blank
    end
    browser.checkbox(:id, target_id).set

    # TODO: get :label 'how' to work
    # browser.checkbox(:label, label_text).set
  end

  When /^I uncheck "([^\"]*)"$/ do |label_text_or_id|
    if label_text_or_id[0,1] == '#'
      target_id = label_text_or_id.sub(/^#/, '')
    else
      lbl = browser.label(:text, /^#{Regexp.escape(label_text_or_id)}/)
      lbl.should exist
      target_id = lbl.target_id
      target_id.should_not be_blank
    end
    browser.checkbox(:id, target_id).set(false)

    # TODO: get :label 'how' to work
    # browser.checkbox(:label, label_text).set(false)
  end

  When /^I choose "([^\"]*)"$/ do |field|
    raise 'Not implemented yet!'
    # choose(field)
  end

  When /^I attach the file at "([^\"]*)" to "([^\"]*)"$/ do |path, field|
    raise 'Not implemented yet!'
    # attach_file(field, path)
  end

  When /^I hover over link "([^\"]*)"$/ do |text|
    browser.link(:text, text).mouse_over
    sleep 1
  end

  Then /^I should see "([^\"]*)"$/ do |text|
    browser.text.should contain(text)
    # response.should contain(text)
  end

  Then /^I should not see "([^\"]*)"$/ do |text|
    browser.text.should_not contain(text)
  end

  Then /^the "([^\"]*)" field should contain "([^\"]*)"$/ do |field, value|
    raise 'Not implemented yet!'
    # field_labeled(field).value.should =~ /#{value}/
  end

  Then /^the "([^\"]*)" field should not contain "([^\"]*)"$/ do |field, value|
    raise 'Not implemented yet!'
    # field_labeled(field).value.should_not =~ /#{value}/
  end
    
  Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
    raise 'Not implemented yet!'
    # field_labeled(label).should be_checked
  end

  Then /^I should be on (.+)$/ do |page_name|
    raise 'Not implemented yet!'
    # URI.parse(current_url).path.should == path_to(page_name)
  end

  Then /^I close browser$/ do
    browser.close
  end

  def watir_path_to path
    'http://localhost:3001' + path_to(path)
  end
end