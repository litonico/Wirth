typedef int bool;
#define true 1
#define false 0
#define NULL 0

enum SymbolKind { TERMINAL, NONTERMINAL };

struct SymDesc;
typedef struct SymDesc *Symbol;

struct HDesc;
typedef struct HDesc *Header;

typedef struct SymDesc {
    enum SymbolKind kind;
    struct SymDesc *alt;
    struct SymDesc *next;

    union {
        int sym; // Terminal
        Header this; // Nonterminal
    };
} SymDesc;

struct HDesc {
    Symbol sym;
};

// Stubs
int sym;
void getSym();

bool parsed(Header hd)
{
    Symbol x = hd->sym;
    bool match;

    for (;;) {
        if (x->kind == TERMINAL) {
            if (x->sym == sym){
                match = true;
                getSym();
            }
            else {
                match = (x == NULL);
            }
        }
        else {
            match = parsed(x->this);
        }
    }
    return match;
}


int main() { return(1); }
