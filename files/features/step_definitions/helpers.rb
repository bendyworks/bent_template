def input_file *dir_and_file_names
  path = dir_and_file_names.join '/'
  relative_path("/../input_files/#{path}")
end

def relative_path path
  File.expand_path("#{File.dirname(__FILE__)}#{path}")
end

def verify_table_contents table_selector, *dir_and_file_names
  file_contents = File.read(expected_output_file("tables", dir_and_file_names))
  expected = eval file_contents
  response.should have_table(table_selector, expected)
end

def expected_output_file *dir_and_file_names
  path = dir_and_file_names.join '/'
  relative_path("/../expected_output_files/#{path}")
end