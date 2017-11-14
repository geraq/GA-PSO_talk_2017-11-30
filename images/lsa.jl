
filename = ARGS[1]

const Sentence = Vector{String}
const Vocab = Dict{String, Int}

function getSentences(filename::String)::Vector{Sentence}
    fid = open(filename)
    sentences = map(x -> split(chomp(x)," "), readlines(fid))
    close(fid)
    sentences
end

function getVocab(sentences::Vector{Sentence})::Vocab
    vocab = Dict{String, Int}()
    foldl((vocab, s) -> foldl((vocab, w) -> begin vocab[w] = get(vocab, w, 0) + 1; vocab end, vocab, s), vocab, sentences)
end

function getDocCounts(sentences::Vector{Sentence})::Dict{String, Int}
    getDocCounts(getVocab(sentences), sentences)
end

function getDocCounts(vocab::Vocab, sentences::Vector{Sentence})::Dict{String, Int}
    counts = Dict(map(k -> k => 0, keys(vocab)))
    #foldl((counts,s) -> foldl((counts, w) -> begin counts[w] += 1; counts end, counts, s), counts, sentences)
    Dict(map(w -> (w, length(filter(s -> w in s, sentences))), keys(vocab)))
end

function getWords(sentences::Vector{Sentence})::Vector{String}
    getWords(getVocab(sentences))
end

function getWords(vocab::Vocab)::Vector{String}
    vocab |> keys |> collect |> sort
end

function getFreqMatrix(sentences::Vector{Sentence})::Matrix{Float64}
    getFreqMatrix(getVocab(sentences), sentences)
end

#word x sent
function getFreqMatrix(vocab::Vocab, sentences::Vector{Sentence})::Matrix{Float64}
    nSentences = length(sentences)
    wordMap = Dict(map(p -> (p[2], p[1]), getWords(vocab) |> enumerate))
    nWords = length(wordMap)
    freqMat = zeros(nWords, nSentences)
    for (j, s) in enumerate(sentences)
        for w in s
            i = wordMap[w]
            freqMat[i,j] += 1
        end
    end
    freqMat
end

function getTF(sentences::Vector{Sentence})::Matrix{Float64}
    getTF(getVocab(sentences), sentences)
end

function getTF(vocab::Vocab, sentences::Vector{Sentence})::Matrix{Float64}
    freqMat = getFreqMatrix(vocab, sentences)
    getTF(freqMat, sentences)
end

function getTF(freqMat::Matrix{Float64}, sentences::Vector{Sentence})::Matrix{Float64}
    tfMat = zeros(Float64, size(freqMat))
    for (i, s) in enumerate(sentences)
        tfMat[:, i] = freqMat[:, i] ./ length(s)
    end
    tfMat
end

function getIDF(sentences::Vector{Sentence})::Dict{String, Float64}
    function getIDF(getVocab(sentences), sentences)
end

function getIDF(vocab::Vocab, sentences::Vector{Sentence})::Dict{String, Float64}
    counts = getDocCounts(vocab, sentences)
    Dict([(w, log(length(sentences) / c)) for (w, c) in counts])
end

function getTFIDF(sentences::Vector{Sentence})::Matrix{Float64}
    getTFIDF(getVocab(sentences), sentences)
end

function getTFIDF(vocab::Vocab, sentences::Vector{Sentence})::Matrix{Float64}
    tfMat = getTF(vocab, sentences)
    idf = getIDF(vocab, sentences)
    idfs = map(w -> idf[w], getWords(vocab))
    for i in 1:size(tfMat, 1)
        tfMat[i, :] *= idfs[i]
    end
    tfMat
end
