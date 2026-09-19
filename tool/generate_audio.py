"""Generates all Spell Combat sound effect WAV assets procedurally.

Run with: python3 tool/generate_audio.py
Produces 16-bit PCM mono WAV files under assets/audio/.
No external dependencies (stdlib only).
"""
import math
import struct
import wave
import os

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def _envelope(i, n, attack=0.05, release=0.35):
    """Simple attack/release envelope, values in [0, 1]."""
    attack_n = max(1, int(n * attack))
    release_n = max(1, int(n * release))
    if i < attack_n:
        return i / attack_n
    if i > n - release_n:
        return max(0.0, (n - i) / release_n)
    return 1.0


def _write_wave(path, samples):
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", max(-32768, min(32767, int(s)))) for s in samples)
        f.writeframes(frames)


def tone(freq_start, freq_end, duration, wave_shape="sine", volume=0.5, attack=0.05, release=0.35, harmonics=None):
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        progress = i / n
        freq = freq_start + (freq_end - freq_start) * progress
        phase = 2 * math.pi * freq * t
        if wave_shape == "square":
            val = 1.0 if math.sin(phase) >= 0 else -1.0
        elif wave_shape == "triangle":
            val = 2 * abs(2 * ((freq * t) % 1) - 1) - 1
        else:
            val = math.sin(phase)
        if harmonics:
            for ratio, amp in harmonics:
                val += amp * math.sin(phase * ratio)
            val /= 1 + sum(amp for _, amp in harmonics)
        env = _envelope(i, n, attack, release)
        samples.append(val * env * volume * 32767)
    return samples


def noise_burst(duration, volume=0.4, seed=12345, low_freq=120):
    n = int(SAMPLE_RATE * duration)
    samples = []
    state = seed
    for i in range(n):
        state = (1103515245 * state + 12345) & 0x7FFFFFFF
        noise = (state / 0x7FFFFFFF) * 2 - 1
        t = i / SAMPLE_RATE
        thump = math.sin(2 * math.pi * low_freq * t)
        env = _envelope(i, n, attack=0.02, release=0.6)
        samples.append((noise * 0.5 + thump * 0.5) * env * volume * 32767)
    return samples


def concat(*parts):
    out = []
    for p in parts:
        out.extend(p)
    return out


def mix(*parts):
    length = max(len(p) for p in parts)
    out = [0.0] * length
    for p in parts:
        for i, v in enumerate(p):
            out[i] += v
    peak = max(1.0, max(abs(v) for v in out) / 32767)
    return [v / peak for v in out]


def silence(duration):
    return [0.0] * int(SAMPLE_RATE * duration)


def build_all():
    os.makedirs(OUT_DIR, exist_ok=True)

    _write_wave(
        os.path.join(OUT_DIR, "button_click.wav"),
        tone(720, 640, 0.07, "square", volume=0.35, attack=0.02, release=0.5),
    )

    _write_wave(
        os.path.join(OUT_DIR, "letter_select.wav"),
        tone(700, 1050, 0.09, "sine", volume=0.4, attack=0.02, release=0.6,
             harmonics=[(2, 0.25)]),
    )

    _write_wave(
        os.path.join(OUT_DIR, "letter_deselect.wav"),
        tone(650, 420, 0.08, "sine", volume=0.35, attack=0.02, release=0.6),
    )

    _write_wave(
        os.path.join(OUT_DIR, "word_invalid.wav"),
        tone(220, 140, 0.28, "square", volume=0.32, attack=0.02, release=0.7,
             harmonics=[(1.06, 0.4)]),
    )

    cast_a = tone(420, 980, 0.22, "sine", volume=0.45, attack=0.05, release=0.5,
                  harmonics=[(2, 0.3), (3, 0.15)])
    cast_b = tone(660, 1320, 0.22, "sine", volume=0.25, attack=0.1, release=0.6)
    _write_wave(os.path.join(OUT_DIR, "word_cast.wav"), mix(cast_a, cast_b))

    _write_wave(
        os.path.join(OUT_DIR, "hit_enemy.wav"),
        noise_burst(0.22, volume=0.55, seed=42, low_freq=180),
    )

    _write_wave(
        os.path.join(OUT_DIR, "hit_player.wav"),
        noise_burst(0.26, volume=0.5, seed=77, low_freq=90),
    )

    _write_wave(
        os.path.join(OUT_DIR, "power_word.wav"),
        mix(
            tone(500, 1400, 0.45, "sine", volume=0.35, attack=0.05, release=0.5,
                 harmonics=[(2, 0.3), (4, 0.15)]),
            tone(750, 1900, 0.45, "sine", volume=0.2, attack=0.1, release=0.6),
        ),
    )

    victory = concat(
        tone(523, 523, 0.16, "sine", volume=0.4, attack=0.05, release=0.3, harmonics=[(2, 0.25)]),
        tone(659, 659, 0.16, "sine", volume=0.4, attack=0.05, release=0.3, harmonics=[(2, 0.25)]),
        tone(784, 784, 0.16, "sine", volume=0.4, attack=0.05, release=0.3, harmonics=[(2, 0.25)]),
        tone(1046, 1046, 0.4, "sine", volume=0.45, attack=0.03, release=0.7, harmonics=[(2, 0.3)]),
    )
    _write_wave(os.path.join(OUT_DIR, "victory.wav"), victory)

    defeat = concat(
        tone(392, 392, 0.22, "sine", volume=0.4, attack=0.05, release=0.4, harmonics=[(1.5, 0.2)]),
        tone(311, 311, 0.22, "sine", volume=0.4, attack=0.05, release=0.4, harmonics=[(1.5, 0.2)]),
        tone(220, 220, 0.55, "sine", volume=0.42, attack=0.03, release=0.8, harmonics=[(1.5, 0.25)]),
    )
    _write_wave(os.path.join(OUT_DIR, "defeat.wav"), defeat)

    _write_wave(
        os.path.join(OUT_DIR, "enemy_turn.wav"),
        tone(300, 220, 0.2, "triangle", volume=0.3, attack=0.05, release=0.6),
    )

    _write_wave(
        os.path.join(OUT_DIR, "shuffle.wav"),
        tone(500, 900, 0.16, "triangle", volume=0.3, attack=0.02, release=0.6,
             harmonics=[(1.5, 0.2)]),
    )

    print("Generated audio assets in", os.path.abspath(OUT_DIR))


if __name__ == "__main__":
    build_all()
