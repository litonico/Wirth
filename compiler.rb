$input = "ABC012D3Z9"
$sym = ""
$ptr = 0
def algol_next
  $sym = $input[$ptr]
  $ptr += 1
end
def error
  raise "error"
end

$letters = ("A".."Z").to_a
$digits = (1..9).to_a

def lex_identifiers
  if $letters.include? $sym then algol_next else error end
  while ($letters + $digits).include? $sym do
    next
  end
end

def lex_integers
  if $digits.include? $sym then algol_next else error end
  while digits.include? $sym
    next
  end
end

def fail_recursive_descent
  # A = 'a' A 'c' | b
  if $sym == "a"
    algol_next
    if $sym == A then algol_next else error end # what is 'A'?
    if $sym == "c" then algol_next else error end
  elsif $sym == "b" then algol_next
  else error
  end
end

def proc_a
  # A = 'a' A 'c' | b
  if $sym == "a"
    algol_next
    proc_a
    if $sym == "c" then algol_next else error end
  elsif $sym == "b" then algol_next
  else error
  end
end

# Let's emulate the Oberon language Texts.Read!
#
# An 'input' is similar to a file reader: it keeps track of the current
# reading location in the string.
class Input
  attr_reader :text
  attr_accessor :ptr
  def initialize text
    @text = text
    @ptr = 0
  end

  def eot
    # Oberon strings are null-terminated
    @text[@ptr] == "\0"
  end
end

class Texts
  def self.Read input, ch
    ch[0] = input.text[input.ptr] # Mutuate ch in place
    input.ptr += 1
  end
end

class OberonScanner
  IDENT = 0; LITERAL = 2; LPAREN = 3; LBRAK = 4; LBRACE = 5; BAR = 6; EQL = 7;
  RPAREN = 8; RBRAK = 9; RBRACE = 10; PERIOD = 11; OTHER = 12;

  LETTERS = ("A".."Z").to_a + ("a".."z").to_a
  attr_reader :ch, :r
  attr_accessor :sym, :id

  def initialize program_text
    @r = Input.new program_text
    @ch = ""
    @sym = ""
    @id = []
  end

  def GetSym
    while !r.eot && ch <= " " do Texts.Read(r, ch) end

    case
    when LETTERS.include?(ch)
      @sym = IDENT
      i = 0
      loop do
        @id[i] = String.new ch
        i += 1
        Texts.Read(r, ch)
        break if ch.upcase < "A" || ch.upcase > "Z"
      end
    when ch == "\""
      Texts.Read(r, ch)
      @sym = LITERAL
      i = 0

      while ch != '"' && ch > " " do
        @id[i] = String.new ch
        i += 1
        Texts.Read(r, ch)
      end
      if ch <= " " then error end
      Texts.Read(r, ch)
    when ch == "="
      @sym = EQL
      Texts.Read(r, ch)
    when ch == "("
      @sym = LPAREN
      Texts.Read(r, ch)
    when ch == ")"
      @sym = RPAREN
      Texts.Read(r, ch)
    when ch == "["
      @sym = LBRAK
      Texts.Read(r, ch)
    when ch == "]"
      @sym = RBRAK
      Texts.Read(r, ch)
    when ch == "{"
      @sym = LBRACE
      Texts.Read(r, ch)
    when ch == "}"
      @sym = RBRACE
      Texts.Read(r, ch)
    when ch == "|"
      @sym = BAR
      Texts.Read(r, ch)
    when ch == "."
      @sym = PERIOD
      Texts.Read(r, ch)
    else
      @sym = OTHER
      Texts.Read(r, ch)
    end
  end
end

scanner = OberonScanner.new "hello world\0"
scanner.GetSym
error unless 0 == scanner.sym
error unless "hello" == scanner.id.join
