
module MaterialRequestDef

export MaterialRequest

"""
    MaterialRequest

Specifikace požadavků na materiál.
"""
struct MaterialRequest
    Re_req::Float64       # požadovaná mez kluzu [MPa]
    Tmin::Float64         # minimální provozní teplota [°C]
    welded::Bool          # svařovaný spoj?
    thickness::Float64    # tloušťka [mm]
end

end
