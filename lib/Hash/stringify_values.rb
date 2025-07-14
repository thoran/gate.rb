# Hash/stringify_values.rb
# Hash#stringify_values

# 20250425
# 0.0.0

class Hash
  def stringify_values
    self.inject({}) do |a,e|
      a[e.first] = e.last.to_s
      a
    end
  end
end
