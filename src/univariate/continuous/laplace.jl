doc"""
    Laplace(μ,θ)

The *Laplace distribution* with location `μ` and scale `θ` has probability density function

$f(x; \mu, \beta) = \frac{1}{2 \beta} \exp \left(- \frac{|x - \mu|}{\beta} \right)$

```julia
Laplace()       # Laplace distribution with zero location and unit scale, i.e. Laplace(0.0, 1.0)
Laplace(u)      # Laplace distribution with location u and unit scale, i.e. Laplace(u, 1.0)
Laplace(u, b)   # Laplace distribution with location u ans scale b

params(d)       # Get the parameters, i.e. (u, b)
location(d)     # Get the location parameter, i.e. u
scale(d)        # Get the scale parameter, i.e. b
```

External links

* [Laplace distribution on Wikipedia](http://en.wikipedia.org/wiki/Laplace_distribution)

"""
immutable Laplace <: ContinuousUnivariateDistribution
    μ::Float64
    θ::Float64

    Laplace(μ::Real, θ::Real) = (@check_args(Laplace, θ > zero(θ)); new(μ, θ))
    Laplace(μ::Real) = new(μ, 1.0)
    Laplace() = new(0.0, 1.0)
end

typealias Biexponential Laplace

@distr_support Laplace -Inf Inf


#### Parameters

location(d::Laplace) = d.μ
scale(d::Laplace) = d.θ
params(d::Laplace) = (d.μ, d.θ)


#### Statistics

mean(d::Laplace) = d.μ
median(d::Laplace) = d.μ
mode(d::Laplace) = d.μ

var(d::Laplace) = 2.0 * d.θ^2
std(d::Laplace) = sqrt2 * d.θ
skewness(d::Laplace) = 0.0
kurtosis(d::Laplace) = 3.0

entropy(d::Laplace) = log(2.0 * d.θ) + 1.0


#### Evaluations

zval(d::Laplace, x::Float64) = (x - d.μ) / d.θ
xval(d::Laplace, z::Float64) = d.μ + z * d.θ

pdf(d::Laplace, x::Float64) = 0.5 * exp(-abs(zval(d, x))) / scale(d)
logpdf(d::Laplace, x::Float64) = - (abs(zval(d, x)) + log(2.0 * scale(d)))

cdf(d::Laplace, x::Float64) = (z = zval(d, x); z < 0.0 ? 0.5 * exp(z) : 1.0 - 0.5 * exp(-z))
ccdf(d::Laplace, x::Float64) = (z = zval(d, x); z > 0.0 ? 0.5 * exp(-z) : 1.0 - 0.5 * exp(z))
logcdf(d::Laplace, x::Float64) = (z = zval(d, x); z < 0.0 ? loghalf + z : loghalf + log2mexp(-z))
logccdf(d::Laplace, x::Float64) = (z = zval(d, x); z > 0.0 ? loghalf - z : loghalf + log2mexp(z))

quantile(d::Laplace, p::Float64) = p < 0.5 ? xval(d, log(2.0 * p)) : xval(d, -log(2.0 * (1.0 - p)))
cquantile(d::Laplace, p::Float64) = p > 0.5 ? xval(d, log(2.0 * (1.0 - p))) : xval(d, -log(2.0 * p))
invlogcdf(d::Laplace, lp::Float64) = lp < loghalf ? xval(d, logtwo + lp) : xval(d, -(logtwo + log1mexp(lp)))
invlogccdf(d::Laplace, lp::Float64) = lp > loghalf ? xval(d, logtwo + log1mexp(lp)) : xval(d, -(logtwo + lp))

function gradlogpdf(d::Laplace, x::Float64)
    μ, θ = params(d)
    x == μ && error("Gradient is undefined at the location point")
    g = 1.0 / θ
    x > μ ? -g : g
end

function mgf(d::Laplace, t::Real)
    st = d.θ * t
    exp(t * d.μ) / ((1.0 - st) * (1.0 + st))
end
function cf(d::Laplace, t::Real)
    st = d.θ * t
    cis(t * d.μ) / (1+st*st)
end


#### Sampling

rand(d::Laplace) = d.μ + d.θ*randexp()*ifelse(rand(Bool), 1, -1)


#### Fitting

function fit_mle(::Type{Laplace}, x::Array)
    xc = copy(x)
    a = median!(xc)
    Laplace(a, StatsBase.mad!(xc, a))
end
