# Gravestone Stake Requirements

## Functional Requirements
**FR-1**: C-channel holder at top of stake
**FR-2**: Horizontal protruding ridges on inner walls for texture/grip
**FR-3**: Fits 2cm thick foam gravestone (with tolerance)
**FR-4**: Tapered triangular stake for ground insertion that goes to a point
**FR-4**: A face of the triangle is on the same plane as the closed side of the C-Channel for easy printing
**FR-5**: designed for easy printing with minimal supports

## Dimensional Requirements
**DR-1**: Total stake height: 13cm (130mm)
**DR-2**: Foam thickness accommodation: 2cm (20mm)
**DR-3**: C-channel height: 3cm (30mm)

## Orientation Requirements
**OR-1**: C-channel mouth faces UPWARD (gravestone slides down into it from top)
**OR-2**: C-channel is proper C-shape (three walls: back + left + right, front is open)
**OR-3**: C-channel aligned with stake body (rotated 90° on Z-axis)

## Assembly Requirements
**AR-1**: C-channel is CENTERED on the stake (no X or Y offset)
**AR-2**: NO gap between stake top and C-channel base - they must be connected
**AR-3**: Stake does NOT protrude through the base of the C-channel
**AR-4**: the stake and c-channel must overlap for valid 3d printing

## AR-3 Clarification
The C-channel cavity (where the gravestone sits) must be completely empty - ONLY yellow C-channel walls should be visible, with empty space (green background) in the cavity area. NO dark/blue stake material should appear inside the yellow C-channel structure in the side view.

## Current Issue
Despite multiple attempts to lower the stake, it continues to protrude into the C-channel cavity. The stake body needs to be made even shorter OR the C-channel needs to be repositioned higher to ensure complete clearance.

## Valudate steps
1. create images from the openscad file from multiple angles and validate the requirements
2. create a transulent model of the gravestone for reference and place it in the c-channel.  The dimeensions for the gravestone is:
   20cm w x 40cm h x 2cd d

