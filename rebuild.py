#!/usr/bin/env python3
"""从对话日志重建 card_oh.dart 的完整代码"""
import json
import os

def main():
    dialog_file = 'dialog/2026-06-04.jsonl'
    output_file = 'card_oh_reconstructed.dart'
    
    # 读取对话日志
    with open(dialog_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print(f"Total lines in dialog: {len(lines)}")
    
    # 提取所有 edit_file 操作
    edits = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            for item in data.get('content', []):
                if item.get('type') == 'tool_use' and item.get('name') == 'edit_file':
                    inp = item.get('input', {})
                    if 'card_oh.dart' in inp.get('file_path', ''):
                        edits.append({
                            'line': line_num,
                            'timestamp': data.get('timestamp', ''),
                            'old_text': inp.get('old_text', ''),
                            'new_text': inp.get('new_text', ''),
                        })
        except json.JSONDecodeError:
            continue
    
    print(f"Found {len(edits)} edit_file operations")
    
    # 提取 write_file 操作（可能有完整代码）
    writes = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            for item in data.get('content', []):
                if item.get('type') == 'tool_use' and item.get('name') == 'write_file':
                    inp = item.get('input', {})
                    if 'card_oh.dart' in inp.get('file_path', ''):
                        code = inp.get('content', '')
                        if len(code) > 1000:  # 实质性代码
                            writes.append({
                                'line': line_num,
                                'timestamp': data.get('timestamp', ''),
                                'code': code,
                                'size': len(code),
                            })
        except json.JSONDecodeError:
            continue
    
    print(f"Found {len(writes)} write_file operations with substantial code")
    
    # 打印写入操作的信息
    for w in writes:
        print(f"  Line {w['line']}: {w['size']} chars at {w['timestamp']}")
    
    # 保存分析结果
    analysis = {
        'total_edits': len(edits),
        'total_writes': len(writes),
        'write_details': writes,
        'first_10_edits': [
            {'line': e['line'], 'old_len': len(e['old_text']), 'new_len': len(e['new_text'])}
            for e in edits[:10]
        ]
    }
    
    with open('rebuild_analysis.json', 'w', encoding='utf-8') as f:
        json.dump(analysis, f, ensure_ascii=False, indent=2)
    
    print(f"\nSaved analysis to rebuild_analysis.json")
    
    # 尝试找最新的完整代码
    # 检查是否有大的 read_file 结果
    print("\nSearching for large code snippets in read_file results...")
    
    read_results = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            for item in data.get('content', []):
                if item.get('type') == 'tool_result' and item.get('name') == 'read_file':
                    output = item.get('output', [])
                    if output and isinstance(output, list) and len(output) > 0:
                        code = output[0] if isinstance(output[0], str) else str(output[0])
                        if 'currentCards' in code or 'selectedCardIndex' in code:
                            read_results.append({
                                'line': line_num,
                                'size': len(code),
                                'has_currentCards': 'currentCards' in code,
                                'has_selectedCardIndex': 'selectedCardIndex' in code,
                            })
        except:
            continue
    
    print(f"Found {len(read_results)} read_file results with key patterns")
    for r in read_results[:5]:
        print(f"  Line {r['line']}: {r['size']} chars, currentCards={r['has_currentCards']}, selectedCardIndex={r['has_selectedCardIndex']}")
    
    # 打印前几个 edit 的详细信息
    print("\n" + "="*80)
    print("First 3 edits (detailed):")
    print("="*80)
    
    for i, e in enumerate(edits[:3]):
        print(f"\n--- Edit {i+1} at line {e['line']} ---")
        print(f"Old ({len(e['old_text'])} chars):")
        print(e['old_text'][:300])
        print(f"\nNew ({len(e['new_text'])} chars):")
        print(e['new_text'][:300])

if __name__ == '__main__':
    main()
