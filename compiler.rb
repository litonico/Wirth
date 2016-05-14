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

# Let's emulate the Oberon language 'Texts' module!

# An 'input' is similar to a file reader: it keeps track of the current
# reading location in the string.
class Reader
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

class Writer
  attr_reader :buf

  def initialize
    @buf = ""
  end

  def concat str
    buf << str
  end
end

class Texts
  # Oberon is pretty procedural, so instead of putting implementations on
  # the classes themselves ('writer' and 'reader'), they are on this
  # 'Texts' module.

  # Reader procedures
  def self.Read reader, ch
    ch[0] = reader.text[reader.ptr] # Mutuate ch in place
    reader.ptr += 1
  end

  def self.pos reader
    reader.ptr
  end

  # Writer procedures

  def self.WriteString writer, str
    writer.concat str
  end

  def self.WriteInt writer, i, num_digits
    writer.concat i.to_s[0...num_digits]
  end

  def self.WriteLn writer
    writer.concat "\n"
  end

  def Append log, str
    log << str
  end
end

class OberonScanner
  IDENT = 0; LITERAL = 2; LPAREN = 3; LBRAK = 4; LBRACE = 5; BAR = 6; EQL = 7;
  RPAREN = 8; RBRAK = 9; RBRACE = 10; PERIOD = 11; OTHER = 12;

  LETTERS = ("A".."Z").to_a + ("a".."z").to_a
  attr_reader :ch, :r
  attr_accessor :sym, :id

  def initialize program_text
    @r = Reader.new program_text
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


LOG = ""

class EBNFParser
  attr_accessor :lastpos, :w

  def initialize input
    @scanner = OberonScanner.new input
    @w = Writer.new
    @lastpos = 0
  end

  def getSym
    scanner.GetSym
  end

  def id
    scanner.id
  end

  def sym
    scanner.sym
  end

  def error errno
    pos = Texts.pos(R)
    if pos > lastpos + 4 # Not *too* many errors
      Texts.WriteString(w, " pos"); Texts.WriteInt(w, pos, 6)
      Texts.WriteString(w, " err"); Texts.WriteInt(w, errno, 4); @lastpos = pos
      Texts.WriteString(w, " sym"); Texts.WriteInt(w, sym, 4)
      Texts.WriteLn(w); Texts.Append(LOG, w.buf)
    end
  end

  def record t, id, i
    # I have *no* idea what this is supposed to do. It's omitted from
    # the textbook code in one edition, and an empty proc in another.
    # Maybe appends the literal to a list of literals?
  end

  def production
    # A 'production rule'. Has the form
    # ident = expr
    getSym
    if sym == EQL then getSym else error 7  end
    expression
    if sym == PERIOD then getSym else error 8 end
  end

  def expression
    # One or more 'term's, separated by '|'
    term
    while sym == BAR do
      factor
    end
  end

  def term
    # One or more factors
    factor
    while sym < bar do
      factor
    end
  end

  def factor
    # factor = identifier
    #        | string
    #        | "(" expression ")"
    #        | "[" expression "]"
    #        | "{" expression "}"
    if sym == IDENT
      record(t0, id, 1)
      getSym
    elsif sym == LITERAL
      record(t1, id, 0)
      getSym
    elsif sym == LPAREN
      getSym
      expression
      if sym == RPAREN then getSym else error 2 end
    elsif sym == LBRAK
      getSym
      expression
      if sym == RBRAK then getSym else error 3 end
    elsif sym == LBRACE
      getSym
      expression
      if sym == RBRACE then getSym else error 4 end
    else
      error 5
    end
  end

  def syntax
    # Zero or more 'productions'
    while sym == IDENT do
      production
    end
  end

  def compile
    @lastpos = 0
    Texts.Read(r, ch)
    getSym
    syntax
    Texts.Append(LOG, W.buf)
  end
end
