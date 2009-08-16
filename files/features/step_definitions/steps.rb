Given /^common data(.*$)/ do |modifier|
  # [SomeModel, OtherModel].each do |klass|
  #   klass.delete_all
  # end

  # unless modifier == ' except Some Model'
  #   model_1 = create_some_model
  #   model_2 = create_some_model
  # end
  # if modifier == ' but delete Other Model'
  #   OtherModel.delete_all
  # end
end

Given /^I log in as "([^\"]*)"$/ do |login|
  pending
end

When /^I attach data file "([^\"]*)" to "([^\"]*)"$/ do |filename, label|
  path = input_file 'data_files', "#{filename}"
  attach_file(label, path)
end

When /^I show page in browser$/ do
  save_and_open_page
end

Then /^I should see expected "([^\"]*)" table contents "([^\"]*)"$/ do |table_name, num|
  verify_table_contents ".#{table_name}", "#{table_name}_#{num}"
end

When /^I debug$/ do
  debugger
  x = 1
end