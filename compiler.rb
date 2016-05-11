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
