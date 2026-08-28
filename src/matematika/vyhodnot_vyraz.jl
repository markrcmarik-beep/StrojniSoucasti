# ver: 2026-08-17
## Funkce: vyhodnot_vyraz()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/vyhodnot_vyraz.jl
## Použité balíčky:
#
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
function vyhodnot_vyraz(vyraz_str::String, data::AbstractDict)

    expr = Meta.parse(vyraz_str)

    function eval_expr(x)

        # Číslo
        if x isa Number
            return x

        # Proměnná
        elseif x isa Symbol
            haskey(data, x) ||
                throw(ArgumentError("Nedefinovaná proměnná: $x"))

            return data[x]

        # Výraz
        elseif x isa Expr

            # Unární a binární operace
            if x.head == :call

                op = x.args[1]

                # Povolené operátory
                if op === :+
                    if length(x.args) == 2
                        return +eval_expr(x.args[2])
                    elseif length(x.args) == 3
                        return eval_expr(x.args[2]) + eval_expr(x.args[3])
                    end

                elseif op === :-
                    if length(x.args) == 2
                        return -eval_expr(x.args[2])
                    elseif length(x.args) == 3
                        return eval_expr(x.args[2]) - eval_expr(x.args[3])
                    end

                elseif op === :*
                    return eval_expr(x.args[2]) * eval_expr(x.args[3])

                elseif op === :/
                    return eval_expr(x.args[2]) / eval_expr(x.args[3])

                elseif op === :^
                    return eval_expr(x.args[2]) ^ eval_expr(x.args[3])

                # Matematické funkce
                elseif op === :sqrt
                    return sqrt(eval_expr(x.args[2]))

                elseif op === :sin
                    return sin(eval_expr(x.args[2]))

                elseif op === :cos
                    return cos(eval_expr(x.args[2]))

                elseif op === :tan
                    return tan(eval_expr(x.args[2]))

                elseif op === :abs
                    return abs(eval_expr(x.args[2]))

                elseif op === :log
                    return log(eval_expr(x.args[2]))

                elseif op === :exp
                    return exp(eval_expr(x.args[2]))

                else
                    throw(ArgumentError(
                        "Nepovolená funkce nebo operátor: $op"
                    ))
                end

            else
                throw(ArgumentError(
                    "Nepodporovaný typ výrazu: $(x.head)"
                ))
            end

        else
            throw(ArgumentError(
                "Nepodporovaný typ: $(typeof(x))"
            ))
        end
    end

    return eval_expr(expr)
end
