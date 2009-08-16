require File.expand_path(File.dirname(__FILE__) + "/sequence")

# A_SEQUENCE = Sequence.new{|n| n.to_f }

Fixjour do
  # define_builder(User) do |klass, overrides|
  #   klass.new(:login => "admin", :email => "abc@def.com", :password => "password", :password_confirmation => "password")
  # end
end

def associated sym, overrides
  klass = sym.to_s.pluralize.classify.constantize
  overrides[sym] || klass.find_by_id(overrides["#{sym}_id".to_sym]) || self.send("new_#{sym}")
end
