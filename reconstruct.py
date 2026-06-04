#!/usr/bin/env python3
"""从对话日志重建 card_oh.dart"""
import json
import re

def main():
    filepath = 'dialog/2026-06-04.jsonl'
    
    # 读取对话日志
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print(f"Total lines: {len(lines)}")
    
    # 提取所有涉及 card_oh.dart 的 edit_file
    edits = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            content = data.get('content', [])
            
            for item in content:
                if item.get('type') == 'tool_use':
                    tool_name = item.get('name')
                    tool_input = item.get('input', {})
                    
                    if tool_name == 'edit_file':
                        file_path = tool_input.get('file_path', '')
                        if 'card_oh.dart' in file_path:
                            edits.append({
                                'line': line_num,
                                'old_text': tool_input.get('old_text', ''),
                                'new_text': tool_input.get('new_text', ''),
                            })
                            
        except json.JSONDecodeError:
            continue
    
    print(f"Found {len(edits)} edit operations")
    
    # 从 git 恢复原始版本，然后应用所有修改
    import subprocess
    
    # 获取文件的历史版本
    result = subprocess.run(
        ['git', 'log', '--oneline', '-5', '--', 'lib/apps/card_oh.dart'],
        capture_output=True, text=True, cwd='.'
    )
    print("Git log for card_oh.dart:")
    print(result.stdout)
    
    # 尝试获取第一个提交的版本（最旧的）
    result = subprocess.run(
        ['git', 'log', '--reverse', '--oneline', '-1', '--', 'lib/apps/card_oh.dart'],
        capture_output=True, text=True, cwd='.'
    )
    first_commit = result.stdout.strip().split()[0] if result.stdout.strip() else None
    print(f"First commit: {first_commit}")
    
    if first_commit:
        result = subprocess.run(
            ['git', 'show', f'{first_commit}:lib/apps/card_oh.dart'],
            capture_output=True, text=True, cwd='.'
        )
        if result.returncode == 0:
            content = result.stdout
            print(f"Original file has {len(content)} characters")
            
            # 应用所有修改
            for i, edit in enumerate(edits):
                content = content.replace(edit['old_text'], edit['new_text'])
                if (i + 1) % 10 == 0:
                    print(f"Applied {i+1}/{len(edits)} edits...")
            
            # 保存重建的文件
            with open('lib/apps/card_oh.dart.reconstructed', 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Saved reconstructed file: {len(content)} characters")
        else:
            print("Failed to get original file from git")
    else:
        print("No git history found")

if __name__ == '__main__':
    main()
