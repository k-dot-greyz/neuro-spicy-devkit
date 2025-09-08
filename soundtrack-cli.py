#!/usr/bin/env python3
"""
Genesis Block Soundtrack CLI
Command-line interface for managing your cognitive audio environment
"""

import json
import os
import sys
import webbrowser
from datetime import datetime
from typing import Dict, List, Optional
import random

class SoundtrackManager:
    """Manages the Genesis Block Soundtrack system"""
    
    def __init__(self, config_file: str = "genesis-block-soundtrack.json"):
        self.config_file = config_file
        self.config = self.load_config()
        self.current_state = None
        self.session_start = None
        
    def load_config(self) -> Dict:
        """Load soundtrack configuration"""
        try:
            with open(self.config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"⚠️  Configuration file '{self.config_file}' not found.")
            return {}
    
    def display_header(self):
        """Display the Genesis Block header"""
        print("\n" + "="*60)
        print("🎵 GENESIS BLOCK SOUNDTRACK SYSTEM 🎵")
        print("="*60)
        print("Match the track to the task.")
        print("Use the audio environment to manage your cognitive state.")
        print("="*60 + "\n")
    
    def show_primary_anthem(self):
        """Display primary anthem information"""
        anthem = self.config['genesis_block']['primary_anthem']
        print("🎸 PRIMARY ANTHEM")
        print(f"   {anthem['artist']} - {anthem['track']}")
        print(f"   Duration: {anthem['duration']}")
        print(f"   Purpose: {anthem['purpose']}")
        print(f"   ▸ {anthem['youtube_url']}\n")
    
    def show_playlist(self):
        """Display playlist information"""
        playlist = self.config['genesis_block']['operational_playlist']
        print("📻 OPERATIONAL PLAYLIST")
        print(f"   Name: {playlist['name']}")
        print(f"   Platform: {playlist['platform']}")
        print(f"   ▸ {playlist['url']}\n")
    
    def list_cognitive_states(self):
        """List all available cognitive states"""
        print("🧠 COGNITIVE STATES\n")
        states = self.config['genesis_block']['cognitive_states']
        
        for idx, (state_key, state_info) in enumerate(states.items(), 1):
            icon = self.get_state_icon(state_key)
            print(f"{icon} [{idx}] {state_key.upper().replace('_', ' ')}")
            print(f"      {state_info['description']}")
            print(f"      Duration: {state_info['duration']}")
            print(f"      BPM Range: {state_info['bpm_range']}")
            print()
    
    def get_state_icon(self, state: str) -> str:
        """Get icon for cognitive state"""
        icons = {
            'initialization': '🚀',
            'deep_focus': '🧠',
            'flow_state': '⚡',
            'debugging': '🔍',
            'deployment': '🚢'
        }
        return icons.get(state, '🎵')
    
    def set_cognitive_state(self, state: str):
        """Set the current cognitive state"""
        states = self.config['genesis_block']['cognitive_states']
        
        if state not in states:
            print(f"❌ Unknown state: {state}")
            return
        
        self.current_state = state
        self.session_start = datetime.now()
        
        state_info = states[state]
        icon = self.get_state_icon(state)
        
        print(f"\n{icon} ENTERING {state.upper().replace('_', ' ')} MODE")
        print("="*40)
        print(f"Description: {state_info['description']}")
        print(f"Recommended Duration: {state_info['duration']}")
        print(f"BPM Range: {state_info['bpm_range']}")
        
        if 'characteristics' in state_info:
            print(f"Characteristics: {', '.join(state_info['characteristics'])}")
        
        print("\n✅ Cognitive state activated!")
        print("🎧 Remember to use noise-cancelling headphones for maximum immersion")
    
    def show_guidelines(self):
        """Display usage guidelines"""
        print("📋 USAGE GUIDELINES\n")
        guidelines = self.config['genesis_block']['usage_guidelines']
        
        for guideline in guidelines:
            print(f"  ▸ {guideline}")
        print()
    
    def recommend_artist(self):
        """Recommend a random artist from the list"""
        artists = self.config['genesis_block']['recommended_artists']
        artist = random.choice(artists)
        print(f"🎤 ARTIST RECOMMENDATION: {artist}")
        print(f"   Try searching for '{artist}' on your preferred music platform\n")
    
    def open_playlist(self):
        """Open the playlist in a web browser"""
        url = self.config['genesis_block']['operational_playlist']['url']
        print(f"🌐 Opening playlist in browser...")
        webbrowser.open(url)
    
    def open_anthem(self):
        """Open the primary anthem in a web browser"""
        url = self.config['genesis_block']['primary_anthem']['youtube_url']
        print(f"🌐 Opening primary anthem in browser...")
        webbrowser.open(url)
    
    def interactive_menu(self):
        """Run interactive menu"""
        self.display_header()
        
        while True:
            print("\n🎮 COMMAND MENU")
            print("="*40)
            print("[1] Show Primary Anthem")
            print("[2] Show Operational Playlist")
            print("[3] List Cognitive States")
            print("[4] Set Cognitive State")
            print("[5] Show Usage Guidelines")
            print("[6] Get Artist Recommendation")
            print("[7] Open Playlist in Browser")
            print("[8] Open Anthem in Browser")
            print("[9] Open Web Player")
            print("[0] Exit")
            print("="*40)
            
            choice = input("\nSelect option: ").strip()
            
            if choice == '1':
                self.show_primary_anthem()
            elif choice == '2':
                self.show_playlist()
            elif choice == '3':
                self.list_cognitive_states()
            elif choice == '4':
                self.list_cognitive_states()
                state_num = input("Select state number: ").strip()
                states_list = list(self.config['genesis_block']['cognitive_states'].keys())
                try:
                    state_idx = int(state_num) - 1
                    if 0 <= state_idx < len(states_list):
                        self.set_cognitive_state(states_list[state_idx])
                    else:
                        print("❌ Invalid state number")
                except ValueError:
                    print("❌ Please enter a valid number")
            elif choice == '5':
                self.show_guidelines()
            elif choice == '6':
                self.recommend_artist()
            elif choice == '7':
                self.open_playlist()
            elif choice == '8':
                self.open_anthem()
            elif choice == '9':
                print("🌐 Opening web player...")
                webbrowser.open('soundtrack-player.html')
            elif choice == '0':
                print("\n🎵 Exiting Genesis Block Soundtrack System")
                print("Remember: We can make the world stop.\n")
                break
            else:
                print("❌ Invalid option. Please try again.")

def main():
    """Main entry point"""
    manager = SoundtrackManager()
    
    if not manager.config:
        print("Failed to load configuration. Exiting.")
        sys.exit(1)
    
    # Check for command line arguments
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == 'anthem':
            manager.display_header()
            manager.show_primary_anthem()
        elif command == 'playlist':
            manager.display_header()
            manager.show_playlist()
        elif command == 'states':
            manager.display_header()
            manager.list_cognitive_states()
        elif command == 'guidelines':
            manager.display_header()
            manager.show_guidelines()
        elif command == 'recommend':
            manager.display_header()
            manager.recommend_artist()
        elif command == 'open-playlist':
            manager.open_playlist()
        elif command == 'open-anthem':
            manager.open_anthem()
        elif command == 'web':
            print("🌐 Opening web player...")
            webbrowser.open('soundtrack-player.html')
        elif command in ['init', 'initialization', 'deep_focus', 'flow_state', 'debugging', 'deployment']:
            manager.display_header()
            # Normalize the command to match state keys
            state = command.replace('-', '_')
            if state == 'init':
                state = 'initialization'
            manager.set_cognitive_state(state)
        elif command == 'help':
            print("\n📖 GENESIS BLOCK SOUNDTRACK CLI")
            print("="*40)
            print("Usage: python soundtrack-cli.py [command]")
            print("\nCommands:")
            print("  anthem         - Show primary anthem")
            print("  playlist       - Show operational playlist")
            print("  states         - List cognitive states")
            print("  guidelines     - Show usage guidelines")
            print("  recommend      - Get artist recommendation")
            print("  open-playlist  - Open playlist in browser")
            print("  open-anthem    - Open anthem in browser")
            print("  web           - Open web player")
            print("  initialization - Enter initialization mode")
            print("  deep_focus    - Enter deep focus mode")
            print("  flow_state    - Enter flow state mode")
            print("  debugging     - Enter debugging mode")
            print("  deployment    - Enter deployment mode")
            print("  help          - Show this help message")
            print("\nNo arguments: Interactive menu")
        else:
            print(f"❌ Unknown command: {command}")
            print("Use 'python soundtrack-cli.py help' for available commands")
    else:
        # No arguments - run interactive menu
        manager.interactive_menu()

if __name__ == "__main__":
    main()