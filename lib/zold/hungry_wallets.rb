# frozen_string_literal: true

# Copyright (c) 2018 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
require 'delegate'
require_relative './commands/pull'
require_relative './commands/fetch'
require_relative 'wallet'
module Zold
  # Wallets decorator that adds missing wallets to the queue to be pulled later.
  class HungryWallets < SimpleDelegator
    def initialize(wallets, remotes, copies)
      @wallets = wallets
      @remotes = remotes
      @copies  = copies
      super(@wallets)
    end

    def find(id)
      Zold::Pull.new(wallets: @wallets, remotes: @remotes, copies: @copies).run(['pull', id.to_s, '--quiet-if-absent']) unless wallet_present?(id)
      super(id) do |wallet|
        yield wallet
      end
    end

    private

    def wallet_present?(id)
      File.exist?(File.join(@wallets.path, id.to_s + Wallet::EXT))
    end
  end
end
