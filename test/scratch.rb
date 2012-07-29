require 'binyo'

HEX_TABLE = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102]
HEX_TABLE_INV = [
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, 
  -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 
  13, 14, 15
] #102
HEX_INV_MAX = 102

module BinyoHex

  def self.encode(data)
    input = Binyo::ByteList.new(data)
    bl = Binyo::ByteList.new(data.size * 2)
    input.each do |b|
      bl << HEX_TABLE[b >> 4]
      bl << HEX_TABLE[b & 0x0f]
    end
    bl.to_s
  end

end

data = "test" * 10000
100.times do
  BinyoHex.encode(data)
end


