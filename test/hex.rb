require 'binyo'
require 'benchmark'

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

module Hex

  def self.encode(data)
    ("\0" * (data.size * 2)).tap do |ret|
      data.each_byte.each_with_index do |b, i|
        ret.setbyte(i * 2, HEX_TABLE[b >> 4])
        ret.setbyte(i * 2 + 1, HEX_TABLE[b & 0x0f])
      end
    end
  end

  def self.decode(data)
    len = data.size
    raise RuntimeError.new("Hex-encoded data length must be a multiple of 2") unless len % 2 == 0
    "".tap do |ret|
      (len / 2).times do |i|
        dbl_i = i * 2
        c = data[dbl_i].ord
        d = data[dbl_i + 1].ord
        if c > HEX_INV_MAX || d > HEX_INV_MAX
          raise RuntimeError.new("Illegal hex character detected: #{c}|#{d}")
        end
        b = HEX_TABLE_INV[c]
        raise illegal_hex_char(c) if b < 0
        b = b << 4
        bb = HEX_TABLE_INV[d]
        raise illegal_hex_char(d) if bb < 0
        ret << (b | bb)
      end
    end
  end

  private

  def self.illegal_hex_char(c)
    RuntimeError.new("Illegal hex character detected: #{c}")
  end

end

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

  def self.decode(data)
    raise RuntimeError.new("Hex-encoded data length must be a multiple of 2") unless data.size % 2 == 0
    input = Binyo::ByteList.new(data)
    half_len = data.size / 2
    bl = Binyo::ByteList.new(half_len)
    half_len.times do |i|
      dbl_i = i * 2
      c = input[dbl_i]
      d = input[dbl_i + 1]
      if c > HEX_INV_MAX || d > HEX_INV_MAX
        raise RuntimeError.new("Illegal hex character detected: #{c}|#{d}")
      end
      b = HEX_TABLE_INV[c]
      raise illegal_hex_char(c) if b < 0
      b = b << 4
      bb = HEX_TABLE_INV[d]
      raise illegal_hex_char(d) if bb < 0
      bl << (b | bb)
    end
    bl.to_s
  end

end

Benchmark.bm do |bm|
  n = 1000

  data = "test" * 10000

  bm.report("unpack('H*')") do
    n.times do
      data.unpack("H*")[0]
    end
  end

  bm.report("Hex.encode") do
    n.times do
      Hex.encode(data)
    end
  end

  bm.report("BinyoHex.encode") do
    n.times do
      BinyoHex.encode(data)
    end
  end

  enc = data.unpack("H*")[0]

  bm.report("pack('H*')") do
    n.times do
      [enc].pack("H*")
    end
  end

  bm.report("Hex.decode") do
    n.times do
      Hex.decode(enc)
    end
  end

  bm.report("BinyoHex.decode") do
    n.times do
      BinyoHex.decode(enc)
    end
  end

end

