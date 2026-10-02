#!/usr/bin/env python3
"""Tamil -> Latin transliteration for Thiruppavai verses.
Scheme: doubled long vowels (aa ii uu ee oo); k/g, s/ch, t/d, th/dh, p/b
voicing; T N L R retroflex; zh for ழ; njch for ஞ்ச; chch for ச்ச.
"""
import json

VOW = {'அ': 'a', 'ஆ': 'aa', 'இ': 'i', 'ஈ': 'ii', 'உ': 'u', 'ஊ': 'uu',
       'எ': 'e', 'ஏ': 'ee', 'ஐ': 'ai', 'ஒ': 'o', 'ஓ': 'oo', 'ஔ': 'au'}
VOWS = {'ா': 'aa', 'ி': 'i', 'ீ': 'ii', 'ு': 'u', 'ூ': 'uu', 'ெ': 'e',
        'ே': 'ee', 'ை': 'ai', 'ொ': 'o', 'ோ': 'oo', 'ௌ': 'au', '்': ''}
CONS = {'க': 'k', 'ங': 'ng', 'ச': 's', 'ஞ': 'nj', 'ட': 't', 'ண': 'n',
        'த': 'th', 'ந': 'n', 'ப': 'p', 'ம': 'm', 'ய': 'y', 'ர': 'r',
        'ல': 'l', 'வ': 'v', 'ழ': 'zh', 'ள': 'l', 'ற': 'r', 'ன': 'n',
        'ஜ': 'j', 'ஷ': 'sh', 'ஸ': 's', 'ஹ': 'h'}
RETRO = {'ட': 'T', 'ண': 'N', 'ள': 'L', 'ற': 'R'}
VOICE = {'k': 'g', 's': 's', 't': 'd', 'th': 'dh', 'p': 'b'}
NASALS = {'ங', 'ஞ', 'ண', 'ந', 'ம', 'ன'}


def tokenize(word):
    toks = []
    i, chs = 0, list(word)
    while i < len(chs):
        c = chs[i]
        if c in VOW:
            toks.append(('V', c)); i += 1
        elif c in CONS:
            v, vir = 'a', False
            if i + 1 < len(chs) and chs[i + 1] in VOWS:
                if chs[i + 1] == '்':
                    vir, v = True, ''
                else:
                    v = VOWS[chs[i + 1]]
                i += 2
            else:
                i += 1
            toks.append(('C', c, v, vir))
        else:
            toks.append(('X', c)); i += 1
    return toks


def translit_word(word):
    toks = tokenize(word)
    out = []
    prev_vowel = False
    prev_nasal = False
    prev_vir = None  # consonant char of previous virama token
    for idx, t in enumerate(toks):
        if t[0] == 'V':
            out.append(VOW[t[1]])
            prev_vowel, prev_nasal, prev_vir = True, False, None
        elif t[0] == 'X':
            out.append(t[1])
            prev_vowel, prev_nasal, prev_vir = False, False, None
        else:
            _, c, v, vir = t
            base = RETRO.get(c, CONS.get(c, c))
            if vir:
                out.append('ch' if c == 'ச' else base)
                prev_vowel, prev_nasal, prev_vir = False, c in NASALS, c
                continue
            if prev_vir == c:  # geminate: first consonant already emitted
                if c == 'ச':
                    g = 'ch'
                elif base in ('k', 't', 'th', 'p', 'T', 'N', 'L', 'R'):
                    g = base
                else:
                    g = base
                out.append(g)
                if v:
                    out.append(v)
                prev_vowel, prev_nasal, prev_vir = True, False, None
                continue
            if base in VOICE:
                if idx == 0:
                    b = 's' if c == 'ச' else base
                elif prev_nasal:
                    b = {'k': 'g', 's': 'j', 't': 'd',
                         'th': 'dh', 'p': 'b'}[base]
                    if c == 'ச' and out and out[-1].endswith('nj'):
                        b = 'ch'  # ஞ்ச -> njch
                elif prev_vowel:
                    b = VOICE[base]
                else:
                    b = base
                out.append(b)
            else:
                out.append(base)
            if v:
                out.append(v)
            prev_vowel, prev_nasal, prev_vir = True, False, None
    return ''.join(out)


def translit_line(line):
    return ' '.join(translit_word(w) for w in line.split(' '))


if __name__ == '__main__':
    data = json.load(open('tamil-final.json', encoding='utf-8'))
    res = [{'n': v['n'], 'lines': [translit_line(l) for l in v['tamil']]}
           for v in data]
    json.dump(res, open('translit-raw.json', 'w', encoding='utf-8'),
              ensure_ascii=False, indent=1)
    print('verses:', len(res))
