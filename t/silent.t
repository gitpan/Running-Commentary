use 5.014;

use Running::Commentary;
use Test::Effects;

plan $] >= 5.018 ? (skip_all => 'An apparent bug in Perl 5.18 makes this test always fail')
                 : (tests    => 8);

my $run_sub          = sub { say "loudly ok" };
my $expected_text    = "loudly ok\n";
my $expected_message = '# Loudly';
my $expected_output  = qr/${expected_message}[.]+${expected_text}${expected_message}[.]+done/;
my $expected_silence = q{};


# Disable colour to simplify testing output...
run_with -nocolour;

# Should run normally, will see comments fore and aft...
effects_ok { run $expected_message => $run_sub; }
           { 
                stdout => $expected_output,
           };


{
    # Now disable descriptions...
    run_with -silent;

    effects_ok { run $expected_message => $run_sub; }
               {
                    stdout => $expected_silence,
               };
}

# Should not be -silent back out in this scope...
effects_ok { run $expected_message => $run_sub; }
           { 
                stdout => $expected_output,
           };

# Flag for conditional silent...
my $opt_silent = 1;

{
    # Set silent via conditional...
    run_with -silent if $opt_silent;

    # Will only work if silent set...
    effects_ok { run $expected_message => $run_sub }
               {
                    stdout => $expected_silence,
               };
}

# Should not be -silent back out in this scope...
effects_ok { run $expected_message => sub { say "loudly ok" } }
           { 
                stdout => $expected_output,
           };

{
    # Fail to set silent, via conditional...
    run_with -silent if !$opt_silent;

    # Will only work if silent not set...
    effects_ok { run $expected_message => sub { say "loudly ok" } }
            { 
                    stdout => $expected_output,
            };

    # Explicit -silent overrides...
    effects_ok { run -silent, $expected_message => sub { say "loudly ok" } }
            {
                    stdout => $expected_silence,
            };

    # But explicit -silent not permanent...
    effects_ok { run $expected_message => sub { say "loudly ok" } }
            { 
                    stdout => $expected_output,
            };
}


