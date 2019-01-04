RSpec::Matchers.define :be_sorted_by do
  match do |array|
    array.each_cons(2).all? do |a, b|
      (block_arg.call(a) <=> block_arg.call(b)) <= 0
    end
  end
end
