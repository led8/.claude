# Backend

## Recommended Backend Files

```text
backend/app/
├── api/routes/dashboard.py
├── schemas/dashboard.py
└── main.py
```

## App Entrypoint

```py
# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.dashboard import router as dashboard_router

app = FastAPI(title="Dashboard API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(dashboard_router)
```

## Schemas

```py
# backend/app/schemas/dashboard.py
from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class KpiItem(BaseModel):
    label: str
    value: str
    delta: str


class DashboardKpisResponse(BaseModel):
    items: list[KpiItem]


class RevenuePoint(BaseModel):
    month: str
    revenue: int
    cost: int


class RevenueSeriesResponse(BaseModel):
    points: list[RevenuePoint]


class CustomerRow(BaseModel):
    id: int
    name: str
    segment: str
    mrr: int
    updated_at: date


class CustomerTableResponse(BaseModel):
    items: list[CustomerRow]
    total: int
    page: int = Field(ge=1)
    page_size: int = Field(ge=1, le=100)
    sort: Literal["name", "mrr", "updated_at"]
    order: Literal["asc", "desc"]
```

## Routes

```py
# backend/app/api/routes/dashboard.py
from datetime import date
from typing import Literal

from fastapi import APIRouter, Query

from app.schemas.dashboard import (
    CustomerRow,
    CustomerTableResponse,
    DashboardKpisResponse,
    KpiItem,
    RevenuePoint,
    RevenueSeriesResponse,
)

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])

CUSTOMERS = [
    CustomerRow(id=1, name="Acme Corp", segment="Enterprise", mrr=24000, updated_at=date(2026, 3, 30)),
    CustomerRow(id=2, name="Northwind", segment="Mid-market", mrr=9800, updated_at=date(2026, 3, 28)),
    CustomerRow(id=3, name="Globex", segment="SMB", mrr=4200, updated_at=date(2026, 3, 25)),
]


@router.get("/kpis")
async def get_kpis() -> DashboardKpisResponse:
    return DashboardKpisResponse(
        items=[
            KpiItem(label="MRR", value="$38.0k", delta="+8.4%"),
            KpiItem(label="Net retention", value="112%", delta="+1.3%"),
            KpiItem(label="Active customers", value="243", delta="+12"),
            KpiItem(label="Churn", value="1.9%", delta="-0.4%"),
        ]
    )


@router.get("/revenue")
async def get_revenue() -> RevenueSeriesResponse:
    return RevenueSeriesResponse(
        points=[
            RevenuePoint(month="Jan", revenue=18000, cost=12000),
            RevenuePoint(month="Feb", revenue=22000, cost=14000),
            RevenuePoint(month="Mar", revenue=26000, cost=15500),
            RevenuePoint(month="Apr", revenue=31000, cost=18200),
        ]
    )


@router.get("/customers")
async def get_customers(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=10, ge=1, le=100),
    sort: Literal["name", "mrr", "updated_at"] = Query(default="updated_at"),
    order: Literal["asc", "desc"] = Query(default="desc"),
) -> CustomerTableResponse:
    reverse = order == "desc"
    sorted_rows = sorted(CUSTOMERS, key=lambda row: getattr(row, sort), reverse=reverse)
    start = (page - 1) * page_size
    end = start + page_size
    return CustomerTableResponse(
        items=sorted_rows[start:end],
        total=len(sorted_rows),
        page=page,
        page_size=page_size,
        sort=sort,
        order=order,
    )
```

## Notes

- Keep response models explicit so the OpenAPI schema stays stable for `openapi-typescript`.
- Split KPI, chart, and table endpoints so the frontend can load them independently.
- Use Query validation for pagination and sorting instead of ad hoc parsing.
- Use the generated docs at `/docs` to verify contracts before generating frontend types.
