class Sequence
  attr_reader :proc

  def initialize (&proc) #:nodoc:
    @proc  = proc
    @value = 0
  end

  def next
    @value += 1
    @proc.call(@value)
  end

  def reset
    @value = 0
  end

  def current
    @proc.call(@value)
  end
  alias_method :last, :current
end