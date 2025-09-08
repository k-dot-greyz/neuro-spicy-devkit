### The Genesis Block Soundtrack

> **Primary Anthem:** The Glitch Mob - We Can Make the World Stop
>
> **The Operational Playlist:** [greyZ Foundry OS](https://music.youtube.com/playlist?list=PLvKgYUw_tuTudYkcfgWCc_e9OyDhfFFSI)
>
> This is the official System Audio Profile for the foundry. It is a curated set of frequencies designed to invoke the specific mental states required for the complex tasks of empire construction.
>
> Match the track to the task. Use the audio environment to manage your cognitive state.

### Task-to-track mapping

- **Activation/Kickoff**: Play the Primary Anthem to prime focus and intent.
- **Deep Work/Sprints**: Run the Operational Playlist (shuffle on) and stay heads‑down.
- **Debugging/Triage**: Operational Playlist at lower volume; minimize vocals where possible.
- **Design/Ideation**: Operational Playlist; take brief silent gaps between tracks for synthesis.
- **Review/Docs**: Operational Playlist at medium/low volume to support steady pacing.
- **Break/Reset**: Step away; resume with Operational Playlist to re‑enter flow.

### Quick commands

Install once (make executable):

```bash
chmod +x bin/focus-audio.sh
```

Use anytime:

```bash
# Prime the system
bin/focus-audio.sh activation

# Enter deep work
bin/focus-audio.sh deep

# Debug/triage mode
bin/focus-audio.sh debug

# Design/ideation
bin/focus-audio.sh design

# Open playlist explicitly
bin/focus-audio.sh playlist

# Show mapping/help
bin/focus-audio.sh --help
```

### Notes

- **Volume discipline**: Lower for analysis/writing; slightly higher for execution/flow.
- **Single-source audio**: Avoid competing streams; keep OS alerts minimal during deep work.
- **Fast reset**: If you stall, switch state with `focus-audio.sh activation` then back to `deep`.

