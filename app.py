from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import yfinance as yf
import pandas as pd

app = Flask(__name__)
CORS(app)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/stock-data', methods=['GET'])
def get_stock_data():
    symbol = request.args.get('symbol', 'AAPL')
    interval = request.args.get('interval', '1d')
    period = request.args.get('period', '1mo')
    
    try:
        stock = yf.Ticker(symbol)
        hist = stock.history(period=period, interval=interval)
        
        data = {
            'prices': hist['Close'].tolist(),
            'dates': hist.index.strftime('%Y-%m-%d %H:%M:%S').tolist(),
            'volume': hist['Volume'].tolist(),
            'high': hist['High'].tolist(),
            'low': hist['Low'].tolist(),
            'open': hist['Open'].tolist()
        }
        
        info = stock.info
        company_info = {
            'name': info.get('longName', symbol),
            'sector': info.get('sector', 'N/A'),
            'marketCap': info.get('marketCap', 'N/A'),
            'currentPrice': info.get('currentPrice', 'N/A')
        }
        
        return jsonify({
            'success': True,
            'data': data,
            'info': company_info
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(debug=True)
