# Copyright (c) 2007-2014, Evan Phoenix and contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Rubinius nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Only part of Rubinius' fixnum.rb

# Our Bignum#coerce(Fixnum).first returns a Fixnum and not a Bignum.
# Therefore all Fixnum operations should handle Bignum (or Integer)
# explicitly instead of using coercion.

class Fixnum

  alias_method :modulo, :%

  def coerce(other)
    Rubinius.primitive :fixnum_coerce
    super other
  end

  def fdiv(n)
    if n.kind_of?(Integer) # Truffle: Fixnum => Integer, to handle Bignum as MRI
      to_f / n
    else
      redo_coerced :fdiv, n
    end
  end

  def **(o)
    Rubinius.primitive :fixnum_pow

    if o.is_a?(Float) && self < 0 && o != o.round
      return Complex.new(self, 0) ** o
    elsif o.is_a?(Integer) && o < 0
      return Rational.new(self, 1) ** o
    end

    redo_coerced :**, o
  end

end
