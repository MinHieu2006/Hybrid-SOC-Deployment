import streamlit as st
import paramiko
import ollama
import os      # BẮT BUỘC PHẢI CÓ
import shutil  # BẮT BUỘC PHẢI CÓ

# Cấu hình
VPS_IP = "100.115.141.23" 
SSH_KEY_PATH = "/app/id_ed25519" 

def fetch_logs():
    secure_key_path = "/tmp/id_ed25519_internal"
    
    try:
        # Bước 1: Copy và ép quyền (Vượt qua lỗi 0777 của Windows)
        if os.path.exists(SSH_KEY_PATH):
            shutil.copy2(SSH_KEY_PATH, secure_key_path)
            os.chmod(secure_key_path, 0o600)
        else:
            return "❌ Không tìm thấy file Key tại /app/id_ed25519"
            
        # Bước 2: Kết nối SSH
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # QUAN TRỌNG: Dùng secure_key_path thay vì SSH_KEY_PATH
        ssh.connect(VPS_IP, username="mluong", key_filename=secure_key_path)
        
        # Bước 3: Lấy log (Dùng lệnh tail bình thường)
        stdin, stdout, stderr = ssh.exec_command("tail -n 50 /var/log/apache2/access.log")
        
        error_msg = stderr.read().decode()
        if error_msg:
            return f"❌ Lỗi từ VPS: {error_msg}"
            
        logs = stdout.read().decode()
        ssh.close()
        return logs if logs else "ℹ️ Kết nối thành công nhưng log rỗng."
        
    except Exception as e:
        return f"❌ Lỗi kết nối: {str(e)}"

# Giao diện Streamlit
st.set_page_config(page_title="Yuyashi SOC Dashboard", layout="wide")
st.title("🛡️ Hệ thống Phân tích Log AI - INSA Project")

if 'logs' not in st.session_state:
    st.session_state.logs = ""

with st.sidebar:
    st.header("Cấu hình")
    if st.button("Lấy Log Mới Nhất"):
        with st.spinner('Đang lấy log...'):
            st.session_state.logs = fetch_logs()

# Hiển thị
if st.session_state.logs:
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Raw Logs từ VPS (Pháp)")
        st.code(st.session_state.logs, language="text")
    
    with col2:
        st.subheader("AI Phân tích (Ollama)")
        # Đảm bảo model name trùng với model bạn đã tải (ví dụ qwen2.5:3b)
        if st.button("Bắt đầu phân tích"):
            with st.spinner('AI đang quét log...'):
                try:
                    response = ollama.chat(model='qwen3.5:9b', messages=[
                        {'role': 'user', 'content': f"Phân tích các log này:\n{st.session_state.logs}"}
                    ])
                    st.write(response['message']['content'])
                except Exception as e:
                    st.error(f"Lỗi AI: {str(e)}")